module Kuebiko
  class MessagePayload
    class Document < MessagePayload
      attribute :id, String
      attribute :language_code, String
      attribute :source, String
      attribute :source_id, String

      attribute :created_at, DateTime

      attribute :agent_type, String
      attribute :agent_captured_at, DateTime, default: Time.now

      attribute :version_number, Integer, default: 1
      attribute :version_type, String, default: :original

      attribute :mime_type, String
      attribute :geolocation, Hash

      # Actual content
      attribute :content, Hash
    end
  end
end
