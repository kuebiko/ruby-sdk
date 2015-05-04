module Kuebiko
  class MessagePayload
    class Document < Resource
      # Actual content
      attribute :content, String
      attribute :keywords, Array[String]
      attribute :metadata, Hash
    end
  end
end
