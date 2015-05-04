require 'virtus'

module Kuebiko
  class MessagePayload
    include Virtus.model

    def self.build_from_hash(payload_type, payload)
      type  = payload_type
              .to_s
              .downcase
              .split('/')
              .map do |p|
                p.split('_')
                .map(&:capitalize)
                .join
              end.join('::')

      const_get(type).new(payload)
    rescue NameError
      Generic.new(body: payload)
    end

    def serialize
      attributes.each_with_object({}) do |(key, value), acc|
        acc[key] = if value.respond_to?(:serialize)
                     value.serialize
                   else
                     value
                   end
      end
    end

    def self.payload_type
      class_name = name
      class_name.slice! Kuebiko::MessagePayload.to_s

      class_name
        .split('::')
        .delete_if(&:empty?)
        .map { |p| p.gsub(/([^\^])([A-Z])/, '\1_\2').downcase }
        .join('/')
    end
  end
end
