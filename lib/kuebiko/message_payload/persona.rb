module Kuebiko
  class MessagePayload
    class Persona < Resource
      attribute :language_code, String

      attribute :description, String

      attribute :type, String, default: 'entities.persona'

      attribute :screen_name, String
      attribute :name, String

      # Actual content
      attribute :content, Hash
    end
  end
end
