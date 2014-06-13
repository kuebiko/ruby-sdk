require 'mosquitto'

module Kuebiko
  class MqttClient
    def initialize(options = {})
      @options = options

      # Defaults
      @options[:mqtt_host] ||= 'localhost'
      @options[:mqtt_port] ||= 1883
      @options[:client_id] ||= Process.pid.to_s

      @mqtt = Mosquitto::Client.new(@options[:client_id])

      @outbox = []
      @reply_callbacks = {}
      @subscribed_topics = []

      @on_message_callbacks = []

      initialize_mqtt
    end

    def register_on_message_callback(callback)
      @on_message_callbacks << callback
    end

    def subscribe_to_topic(topic)
      unless @subscribed_topics.find { |v| v[:topic] == topic }
        tid = @subscribed_topics.push(topic: topic, subscribed: false).length - 1
        @mqtt.subscribe(tid, topic, Mosquitto::AT_LEAST_ONCE)
      end
    end

    protected

    def flush_topics
      @subscribed_topics.each_with_index do |t, k|
        unless t[:subscribed]
          @mqtt.subscribe(k, t[:topic], Mosquitto::AT_LEAST_ONCE)
          t[:subscribed] = true
        end
      end
    end

    def flush_messages
    end

    def initialize_mqtt
      setup_mqtt_callbacks

      @mqtt.loop_start
      @mqtt.connect_async(@options[:mqtt_host], @options[:mqtt_port], 10)
    end

    def handle_message(msg)
      @on_message_callbacks.each { |callback| callback.call(msg) }
    end

    def setup_mqtt_callbacks
      @mqtt.on_message do |msg|
        handle_message(msg)
      end

      @mqtt.on_connect do |_|
        flush_topics
      end

      # @mqtt.on_subscribe do |mid, qos|
        # puts "Mqtt on_subscribe: #{mid} -> #{qos}"
        # puts qos
        # @subscribed_topics[mid][:subscribed] = true
      # end
    end
  end
end
