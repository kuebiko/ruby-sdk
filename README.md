# Kuebiko Intro

Kuebiko started off as a though experiment, where I wanted to be able to develop small components (in whatever language) that don't necessarily depend on each other. These agents perform specific tasks that potentially feed back into the network.

The basic architecture is made up of a message broker and any number of agents (pottentially none, but then it wouldn't be doing much would it?) .

Kuebiko defines a few topic rules to ensure that agents are addressable with any required granularity and a list of message types that agents can produce / read.

## Topics

* `hosts/{hostname}/agents/{agent_id}` - Individual agent topic
* `agents` - All agents
* `agents/{agent_type}` - All agents of given type
* `hosts/{hostname}` - All agents in a given host
* `hosts/{hostname}/{agent_type}` - All agents of a certain type in a given host

## Message Payloads

### Generic

* `body`

### Resource

* `id`
* `type`
* `source`
* `source_id`
* `language_code`
* `agent_type`
* `agent_captured_at`
* `created_at`
* `version_number`
* `version_type`
* `mime_type`
* `geolocation`

#### Persona

* `description`
* `screen_name`
* `name`
* `content`

#### Document

* `content` - string
* `keywords` - Array(string)
* `metadata` - Hash

### Query

* `query`

### System Command

#### Ping
#### Shutdown


### Resource Pointer

* `id`
* `type`
* `source`
* `source_id`

### Resource Relationship

* `start_node`
* `end_node`
* `type`
