require 'virtus'

module Kuebiko
  class Message
    include Virtus.model

    attribute :created_at, DateTime

    attribute :message_id, String

    attribute :send_to, Array[String]
    attribute :reply_to, String

    attribute :sent_at, DateTime

    attribute :payload_type, String
    attribute :payload, MessagePayload

    def initialize(attributes = nil)
      @created_at = Time.now
      super
    end

    def type
      self.class.name.to_s
    end

    def to_json
      attributes.to_json
    end

    def self.build_from_hash(msg_hash)
      payload = msg_hash.delete(:payload)

      new(msg_hash).tap do |msg|
        msg.payload = MessagePayload.build_from_hash(msg_hash[:payload_type], payload)
      end
    end
  end
end
