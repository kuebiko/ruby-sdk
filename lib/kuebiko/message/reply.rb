module Kuebiko
  class Message
    class Reply < Message
      attribute :original_message_id, String
      attribute :node_type, String
      attribute :node_id, String
    end
  end
end