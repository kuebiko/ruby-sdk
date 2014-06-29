module Kuebiko
  class MessagePayload
    class Document < Resource
      # Actual content
      attribute :content, Hash
    end
  end
end
