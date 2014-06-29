module Kuebiko
  class MessagePayload
    class ResourcePointer < MessagePayload
      attribute :id, String
      attribute :type, String
      attribute :source, String
      attribute :source_id, String
    end
  end
end
