require 'json'

module Kuebiko
  # Handles routing of incoming messages to registered callbacks and handles
  # outgoing messages, optionally registering a reply callback and individually
  # ID'ing messages
  class Dispatcher
    attr_reader :message_router

    # Initialize a message Dispatcher
    #
    # @param [MqttClient] mqtt_client
    # @param [String] reply_topic
    #
    # @return [undefined]
    #
    #
    def initialize(mqtt_client, reply_topic, options = {})
      @mqtt_client = mqtt_client

      # Initialize
      @outbox = []
      @reply_callbacks = {}
      @handlers = {}
      @waiting_reply = {}
      @reply_topic = reply_topic

      @message_serialized_class = options.fetch(:message_serializer_class) do
        Kuebiko::MessageSerializer
      end

      @mqtt_client.register_on_message_callback(method(:route))
    end

    # Registers a message handler for a specific message type on a specific
    # topic.
    #
    # @todo Allow and properly handle MQTT topic wildcard syntax
    #
    # @param [String] topic
    # @param [MessagePayload] message_type
    # @param [Method] callback
    #
    # @return [undefined]
    def register_message_handler(topic, message_type, callback)
      if message_type.respond_to?(:payload_type)
        message_type = message_type.payload_type
      end

      @handlers[topic] ||= {}
      @handlers[topic][message_type] ||= []

      @handlers[topic][message_type] << callback

      # Listen to topic
      @mqtt_client.subscribe_to_topic(topic)
    end

    # Sends a message to the message queue. If a callback is registered an ID
    # is generated, the reply_to topic filled out and the callback registered
    # before sending
    #
    # @param [Message] message
    # @param [] callback
    #
    # @api Public
    def send(message, callback = nil)
      message.message_id = Random.srand

      if callback
        message.reply_to = @reply_topic
        @waiting_reply[message.message_id] = callback
      end

      publish_message(message)
    rescue Mosquitto::Error
      @outbox << message
    end

    protected

    # Routes an incoming message to the appropriate handlers (if any)
    #
    # @param [String] mqtt_message
    #
    # @return [undefined]
    #
    def route(mqtt_message)
      topic = mqtt_message.topic
      message = build_message

      # Replies are received through the reply_to topic and should contain
      # the original message id. If message is a reply but no handler is
      # registered, message is dropped and not sent to the global handler list
      if reply?(topic, message)
        handle_reply(message)
      else
        handle(topic, message)
      end
    end

    def flush_message_queue
      queue_to_process = []
      @outbox.reject! { |v| queue_to_process << v }

      queue_to_process.each { |msg| send(msg) }
    end

    def build_message(raw_message)
      Message.build_from_hash(
        JSON.parse(raw_message.to_s, symbolize_names: true)
      )

    rescue StandardError => e
      puts e.inspect
    rescue JSON::ParserError
      # TODO: Proper log this you idiot
      puts 'Invalid message payload'
    end

    def reply?(topic, message)
      topic == @reply_topic && message.original_message_id
    end

    def reply_handler?(message_id)
      @waiting_reply.include?(message_id)
    end

    def handler_available?(topic, payload_type)
      @handlers[topic] && @handlers[topic][payload_type]
    end

    def handle_reply(message)
      return nil unless reply_handler?(message.original_message_id)

      @waiting_reply[message.original_message_id].call(message)
    end

    def handle(topic, message)
      return nil unless handler_available(topic, message.payload_type)

      @handlers[topic][message.payload_type].each do |callback|
        begin
          callback.call(message)
        rescue StandardError => e
          puts "Error calling handler callback: #{e.message}"
        end
      end
    end

    def publish_message(message)
      message.send_to.each do |topic|
        @mqtt_client.publish(
          nil,
          topic,
          @message_serialized_class.call(message),
          Mosquitto::AT_LEAST_ONCE,
          true
        )
      end
    end
  end
end
