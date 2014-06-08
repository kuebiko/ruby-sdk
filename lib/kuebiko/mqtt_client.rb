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

      @on_message_callbacks = []

      initialize_mqtt
    end

    def register_on_message_callback(callback)
      @on_message_callbacks << callback
    end

    def subscribe_to_topic(topic)
      puts @mqtt.subscribe(nil, topic, Mosquitto::AT_LEAST_ONCE)
    end

    protected

    def initialize_mqtt
      setup_mqtt_callbacks

      @mqtt.loop_start
      @mqtt.connect_async(@options[:mqtt_host], @options[:mqtt_port], 10)
    end

    def handle_message(msg)
      @on_message_callbacks.each { |callback| callback.call(msg) }
    end

    def setup_mqtt_callbacks
      @mqtt.on_message { |msg| handle_message(msg); puts "Mqtt on_message" }
      # @mqtt.on_connect { |_| puts 'Mqtt on_connect' }
      # @mqtt.on_subscribe { |_, _| puts 'Mqtt on_subscribe' }
    end
  end
end
