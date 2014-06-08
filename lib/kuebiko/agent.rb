require 'celluloid/autostart'

module Kuebiko
  class Agent
    include Celluloid

    attr_accessor :mqtt_client, :dispatcher

    def initialize(options = {})
      @hostname = options.fetch(:hostname) { Socket.gethostname }
      @client_id = options.fetch(:client_id) { Process.pid.to_s }
      @mqtt_client = options.fetch(:mqtt_client) { Kuebiko::MqttClient.new(client_id: @client_id) }
      @dispatcher = options.fetch(:dispatcher) { Dispatcher.new(@mqtt_client) }

      @shutdown_agent = false

      trap('TERM') { shutdown! }
      trap('INT')  { shutdown! }
      trap('SIGTERM') { shutdown! }
    end

    def shutdown!
      puts 'Requesting shutdown'
      terminate
    end

    def ping
      puts 'pong'
    end
  end
end
