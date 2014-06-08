require 'celluloid/autostart'

module Kuebiko
  class Agent
    include Celluloid

    attr_accessor :mqtt_client, :dispatcher, :agent_id, :agent_type, :hostname

    def initialize(options = {})
      @hostname = options.fetch(:hostname) { Socket.gethostname }
      @agent_id = options.fetch(:agent_id) { Process.pid.to_s }
      @agent_type = options.fetch(:agent_type) { self.class.name }
      @mqtt_client = options.fetch(:mqtt_client) { Kuebiko::MqttClient.new(client_id: @client_id) }
      @dispatcher = options.fetch(:dispatcher) { Dispatcher.new(@mqtt_client) }

      @shutdown_agent = false

      trap('TERM') { handle_shutdown }
      trap('INT')  { handle_shutdown }
      trap('SIGTERM') { handle_shutdown }

      register_system_handlers
    end

    def register_system_handlers
      { 'Ping' => :handle_ping, 'Shutdown' => :handle_shutdown }.each do |command, handler|
        agent_topics.each do |topic|
          dispatcher.register_message_handler(
            topic,
            Kuebiko::Message::SystemCommand.const_get(command),
            method(handler)
          )
        end
      end
    end

    def handle_ping(_)
      puts "PONG"
    end

    def handle_shutdown(_)
      puts 'Requesting shutdown'
      terminate
    end

    def agent_topics
      [
        [hostname],
        [hostname, 'agents', agent_id],
        [hostname, agent_type]
      ].map { |topic| topic.join('/') }
    end
  end
end
