require 'mosquitto'

module Kuebiko
  class InboundDispatcher
    def initialize(client_id, host = 'localhost', port = 1883)
      @mqtt = Mosquitto::Client.new(client_id)
      # @mqtt.logger = Logger.new(STDOUT)

      @mqtt.loop_start

      @mqtt.connect_async(host, port, 10)

      @mqtt.on_connect do |_|
        ['host', 'host/agent', "host/agent/#{client_id}"].each do |topic|
          @mqtt.subscribe(nil, topic, Mosquitto::AT_LEAST_ONCE)
        end
      end

      @mqtt.on_message { |msg| handle_message(msg) }
    end

    def handle_message(message)
      puts message.to_s
    end
  end
end
