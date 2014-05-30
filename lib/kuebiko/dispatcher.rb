require 'mosquitto'
require 'socket'

module Kuebiko
  class Dispatcher
    def initialize(options = {})
      @options = options

      # Defaults
      @options[:mqtt_host] ||= 'localhost'
      @options[:mqtt_port] ||= 1883
      @options[:client_id] ||= Process.pid.to_s

      @mqtt = Mosquitto::Client.new(@options[:client_id])

      initialize_mqtt
    end

    def route(message)
      puts message.to_s
    end

    def send(message)
    end

    protected

    def initialize_mqtt
      initialize_mqtt_callbacks

      @mqtt.loop_start

      @mqtt.connect_async(@options[:mqtt_host], @options[:mqtt_port], 10)
    end

    def initialize_mqtt_callbacks
      @mqtt.on_connect { |_| setup_mqtt_topics }
      @mqtt.on_message { |msg| route(msg) }
    end

    def setup_mqtt_topics
      mqtt_topics.each { |topic| @mqtt.subscribe(nil, topic, Mosquitto::AT_LEAST_ONCE) }
    end

    def mqtt_topics
      ['agents', hostname, @options[:client_id]].reduce([]) do |acc, val|
        acc << (acc + [val]).join('/')
        acc
      end
    end

    def hostname
      Socket.gethostname
    end
  end
end
