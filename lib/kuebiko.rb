# Base module for the Kuebiko Ruby SDK
module Kuebiko; end

require 'kuebiko/agent'
require 'kuebiko/dispatcher'

require 'kuebiko/message_payload.rb'

require 'kuebiko/message_payload/generic'
require 'kuebiko/message_payload/query'
require 'kuebiko/message_payload/resource'
require 'kuebiko/message_payload/resource_pointer'
require 'kuebiko/message_payload/persona'
require 'kuebiko/message_payload/resource_relationship'
require 'kuebiko/message_payload/document'
require 'kuebiko/message_payload/system_command'
require 'kuebiko/message_payload/system_command/ping'
require 'kuebiko/message_payload/system_command/shutdown'

require 'kuebiko/message'
require 'kuebiko/message_serializer'

require 'kuebiko/mqtt_client'
