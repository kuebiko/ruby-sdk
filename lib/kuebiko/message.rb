require 'virtus'

module Kuebiko
  class Message
    class NoReplyInformationPresent < StandardError; end
    class NoMessageIdPresent < StandardError; end

    include Virtus.model

    attribute :created_at, DateTime

    attribute :message_id, String

    attribute :send_to, Array[String]
    attribute :reply_to, String
    attribute :original_message_id, String

    attribute :sent_at, DateTime

    attribute :payload_type, String
    attribute :payload, MessagePayload

    def initialize(attributes = nil)
      @created_at = Time.now
      super
    end

    def type
      payload.class.payload_type if payload
    end

    def build_reply_message
      fail NoReplyInformationPresent if reply_to.nil? || reply_to.empty?
      fail NoMessageIdPresent if message_id.nil? || message_id.empty?

      self.class.new(send_to: [reply_to], original_message_id: message_id)
    end

    def self.build_from_hash(msg_hash)
      payload = msg_hash.delete(:payload)

      new(msg_hash).tap do |msg|
        msg.payload = MessagePayload.build_from_hash(msg_hash[:payload_type], payload)
      end
    end
  end
end
