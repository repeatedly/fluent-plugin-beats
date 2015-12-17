# fluent-plugin-beats

[Fluentd](http://fluentd.org) plugin to accept events from [Elastic Beats](https://www.elastic.co/products/beats).

This plugin uses lumberjack protocol for communicating with each beat.

## Installation

    $ gem install fluent-plugin-beats

## Configuration

Configuration example:

    <source>
      @type beats
      metadata_as_tag
    </source>

    # Forward all events from beats to each index on elasticsearch
    <match *beat>
      @type elasticsearch_dynamic
      logstash_format true
      logstash_prefix ${tag_parts[0]}
      type_name ${record['type']}
    </match>

**port**

  The port to listen to. Default Value is `5044`.

**bind**

  The bind address to listen to. Default Value is 0.0.0.0 (all addresses)

**tag**

  The tag of the event.

**metadata_as_tag**

  Use `record['@metadata']['beat']` value instead of fixed tag. Available values are `filebeat`, `packetbeat` and `topbeat`.

**format**

  The format of the log. This format is used for `message` field of `filebeat` event. See Parser article for more detail: http://docs.fluentd.org/articles/parser-plugin-overview

**max_connections**

  Limit the number of connections from beat instances. Default is unlimited.

**use_ssl**, **ssl_certificate**, **ssl_key**, **ssl_key_passphrase**

  For lumberjack protocol.

## Note

* `lumberjack` directory is copied from `logstash-input-beats` and bit modified.
  * Add `Server::Connection#closed?` to check connection is dead or not
  * Remove `id_stream` argument from `Server::Connection#run` block
* From lumberjack limitation, this plugin launches one thread for each connection. You can mitigate this problem by `max_connections`.