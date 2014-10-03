module Kuebiko
  class MessageUnserializer
    def self.call(message_hash)
      payload = message_hash.delete(:payload)

      new(message_hash).tap do |msg|
        msg.payload = MessagePayload.build_from_hash(message_hash[:payload_type], payload)
      end
    end
  end
end
