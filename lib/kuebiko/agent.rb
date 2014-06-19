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
      @dispatcher = options.fetch(:dispatcher) { Dispatcher.new(@mqtt_client, agent_reply_topic) }

      @shutdown_agent = false

      trap('TERM') { handle_shutdown }
      trap('INT')  { handle_shutdown }
      trap('SIGTERM') { handle_shutdown }

      register_system_handlers
    end

    def register_system_handlers
      { 'Ping' => :handle_ping, 'Shutdown' => :handle_shutdown }.each do |command, handler|
        agent_control_topics.each do |topic|
          dispatcher.register_message_handler(
            topic,
            Kuebiko::MessagePayload::SystemCommand.const_get(command),
            method(handler)
          )
        end
      end
    end

    def handle_ping(_ = nil)
      puts "PONG"
    end

    def handle_shutdown(_ = nil)
      Actor.all.each(&:terminate!)
    end

    def agent_reply_topic
      [:hosts, hostname, :agents, agent_id].join('/')
    end

    def agent_control_topics
      [
        [:agents],
        [:agents, agent_type],
        [:hosts, hostname],
        [:hosts, hostname, agent_type]
      ].map { |topic| topic.join('/') } << agent_reply_topic
    end
  end
end
