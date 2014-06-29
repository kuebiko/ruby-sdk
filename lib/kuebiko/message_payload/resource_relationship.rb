module Kuebiko
  class MessagePayload
    class ResourceRelationship < MessagePayload
      attribute :start_resource, ResourcePointer
      attribute :end_resource, ResourcePointer

      attribute :type, String
    end
  end
end
