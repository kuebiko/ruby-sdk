require 'json'

module Kuebiko
  class Dispatcher
    attr_reader :message_router

    def initialize(mqtt_client, reply_topic, options = {})
      @mqtt_client = mqtt_client

      # Initialize
      @outbox = []
      @reply_callbacks = {}
      @handlers = {}
      @waiting_reply = {}
      @reply_topic = reply_topic

      @mqtt_client.register_on_message_callback(method(:route))
    end

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

    def route(mqtt_message)
      msg = Kuebiko::Message.build_from_hash JSON.parse(mqtt_message.to_s, symbolize_names: true)

      ## Replies are received through the reply_to topic and should contain the original message id
      if mqtt_message.topic == @reply_topic && msg.original_message_id
        if @waiting_reply.include?(msg.original_message_id)
          @waiting_reply[msg.original_message_id].call(msg)
        end
      else
        if @handlers[mqtt_message.topic]
          if @handlers[mqtt_message.topic][msg.payload_type]

            @handlers[mqtt_message.topic][msg.payload_type].each do |callback|
              begin
                callback.call(msg)
              rescue StandardError => e
                puts "Error calling handler callback: #{e.message}"
              end
            end
          end
        end
      end

    rescue StandardError => e
      puts e.inspect
    rescue JSON::ParserError
      # TODO: Proper log this you idiot
      puts 'Invalid message payload'
    end

    # Sends
    def send(message, callback = nil)
      message.message_id = Random.srand

      if callback
        message.reply_to = @reply_topic
        @waiting_reply[message.message_id] = callback
      end

      message.send_to.each do |topic|
        @mqtt_client.publish(nil, topic, Kuebiko::MessageSerializer.call(message), Mosquitto::AT_LEAST_ONCE, true)
      end
    rescue Mosquitto::Error
      @outbox << message
    end

    def flush_message_queue
      queue_to_process = []
      @outbox.reject! { |v| queue_to_process << v }

      queue_to_process.each { |msg| send(msg) }
    end
  end
end
