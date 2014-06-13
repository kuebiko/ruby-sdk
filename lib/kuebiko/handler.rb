module Kuebiko
  class Handler
    def initialize(message, dispatcher = nil)
      @message = message
      @dispatcher = dispatcher
    end

    def call
      fail 'Not implemented yet'
    end
  end
end
