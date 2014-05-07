module Kuebiko
  class Message
    class Addressable < Message
      attribute :message_id, String
      attribute :reply_queue, String
    end
  end
end
