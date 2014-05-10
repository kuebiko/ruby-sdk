require 'virtus'

module Kuebiko
  class Message
    include Virtus.model

    attribute :payload, String
    attribute :created_at, DateTime

    def type
      self.class.name.to_s
    end

    def to_json
      attributes.to_json
    end

    def self.build_from_hash(msg)
      type  = msg[:type].to_s.downcase.split('_').map(&:capitalize).join
      Message.const_get("#{type}").new(msg)
    rescue NameError
      Message::Generic.new(msg)
    end
  end
end
