module Kuebiko
  class Message
    class Command < Addressable
      attribute :command, String
    end
  end
end
