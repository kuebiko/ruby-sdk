require 'json'

module Kuebiko
  class Dispatcher
    attr_reader :message_router

    def initialize(mqtt_client, options = {})
      @mqtt_client = mqtt_client

      # Initialize
      @outbox = []
      @reply_callbacks = {}
      @handlers = {}

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
      if @handlers[mqtt_message.topic]
        msg = Kuebiko::Message.build_from_hash JSON.parse(mqtt_message.to_s, symbolize_names: true)

        if @handlers[mqtt_message.topic][msg.type]

          @handlers[mqtt_message.topic][msg.type].each do |callback|
            begin
              callback.call(msg)
            rescue StandardError => e
              puts "Error calling handler callback: #{e.message}"
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
