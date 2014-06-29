module Kuebiko
  class MessagePayload
    class Resource < MessagePayload
      attribute :id, String
      attribute :type

      attribute :source, String
      attribute :source_id, String

      attribute :language_code, String

      attribute :agent_type, String
      attribute :agent_captured_at, DateTime, default: Time.now

      attribute :created_at, DateTime

      attribute :version_number, Integer, default: 1
      attribute :version_type, String, default: :original

      attribute :mime_type, String
      attribute :geolocation, Hash
    end
  end
end
