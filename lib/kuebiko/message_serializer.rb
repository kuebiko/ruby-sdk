module Kuebiko
  class MessageSerializer
    def self.call(msg)
      results = msg.attributes
      results[:payload] = results[:payload].serialize
      results.to_json
    end
  end
end
