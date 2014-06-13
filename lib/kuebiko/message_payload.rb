require 'virtus'

module Kuebiko
  class MessagePayload
    include Virtus.model

    def self.build_from_hash(payload_type, payload)
      type  = payload_type
                .to_s.downcase
                .split('/')
                .map {|p|
                  p.split('_')
                  .map(&:capitalize)
                  .join
                }.join('::')

      const_get(type).new(payload)
    rescue NameError
      Generic.new(payload)
    end
  end
end
