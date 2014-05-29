require 'mosquitto'
# require 'mqtt'
# require 'celluloid'
require 'celluloid/io'
require 'celluloid/autostart'

module Kuebiko
  class InboundDispatcher
    include Celluloid
    finalizer :shutdown

    def initialize(host = 'localhost', port = 1883)
      puts "Connecting to #{host} on port #{port}"

      # @mqtt = MQTT::Client.connect(host, port)
      # @mqtt.subscribe('host', 'host/agent', 'host/agent/123')

      @mqtt = Mosquitto::Client.new('blocking')
      # @mqtt.connect_async(host, port, 10)

      @mqtt.loop_start

      @mqtt.on_message do |msg|
        puts "on_message: #{msg.inspect}"
        async.handle_message(msg)
      end

      @mqtt.on_connect do |rc|
        puts 'on_connect'
        ['host', 'host/agent', 'host/agent/123'].each { |t| @mqtt.subscribe(nil, t, Mosquitto::AT_MOST_ONCE) }
      end

      @mqtt.connect(host, port, 10)
      # async.run
    end

    def run
      puts "I'm listening"
      # loop do
      @mqtt.get do |topic, payload|
        puts 'got something'
        async.handle_message topic, payload
      end
      # end
      # loop { async.handle_message @mqtt.get }
    end

    # def shutdown
    #   @mqtt.disconnect
    # end

    # def handle_message(topic, message)
    def handle_message(message)
      puts 'O dear, work to do'
      puts message.inspect
    end
  end
end
