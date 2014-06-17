module Kuebiko
  class MessagePayload
    class Query < MessagePayload
      attribute :query, String
    end
  end
end
