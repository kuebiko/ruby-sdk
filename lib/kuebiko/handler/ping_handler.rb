module Kuebiko
  class Handler
    class Ping < Handler
      def call
        @publisher.publish(message.reply_queue, :pong, message.message_id)
      end
    end
  end
end
