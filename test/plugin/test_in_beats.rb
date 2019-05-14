require 'fluent/test'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_beats'
require 'lumberjack/beats/client'
require 'helper'

class BeatsInputTest < Test::Unit::TestCase

  def setup
    Fluent::Test.setup
  end

  PORT = find_available_port

  CONFIG = %[
    port #{PORT}
    bind 127.0.0.1
    tag test.beats
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::BeatsInput).configure(conf)
  end

  def create_client
    Lumberjack::Beats::Client.new({
        :port => PORT,
        :addresses => ['127.0.0.1'],
        :json => true,
        :ssl => false
    })
  end

  def test_configure
    d = create_driver
    assert_equal PORT, d.instance.port
    assert_equal '127.0.0.1', d.instance.bind
    assert_equal 'test.beats', d.instance.tag
    assert_false d.instance.use_ssl
    assert_nil d.instance.ssl_certificate
    assert_nil d.instance.ssl_key
    assert_nil d.instance.ssl_key_passphrase
    assert_nil d.instance.ssl_version
    assert_nil d.instance.ssl_ciphers
  end

  def test_configure_without_tag_parameters
    assert_raise Fluent::ConfigError.new("'tag' or 'metadata_as_tag' parameter is required on beats input") do
      create_driver('')
    end
  end

  def test_send_beat
    d = create_driver

    timestamp = '2018-01-01T12:30:00.000Z'
    payload = {
        '@metadata' => {'beat' => 'heartbeat'},
        '@timestamp' => timestamp,
        'foo' => 'bar'
    }

    d.run do
      client = create_client
      client.write(payload)
    end

    es = d.events
    assert_equal es[0][0], 'test.beats'
    assert_equal es.length, 1

    tag, time, record = es[0]
    assert_equal time.to_i, Time.parse(timestamp).to_i
    assert_equal record, payload
  end

  def test_metadata_as_tag
    d = create_driver(CONFIG + 'metadata_as_tag')

    timestamp = '2018-01-01T12:30:00.000Z'
    payload = {
        '@metadata' => {'beat' => 'heartbeat'},
        '@timestamp' => timestamp,
        'foo' => 'bar'
    }

    d.run do
      client = create_client
      client.write(payload)
    end

    es = d.events
    assert_equal es[0][0], 'heartbeat'
    assert_equal es.length, 1

    tag, time, record = es[0]
    assert_equal time.to_i, Time.parse(timestamp).to_i
    assert_equal record, payload
  end

  def test_input_as_json
    d = create_driver(CONFIG + %[format json])

    timestamp = '2018-01-01T12:30:00.000Z'
    payload = {
        '@metadata' => {'beat' => 'heartbeat'},
        '@timestamp' => timestamp,
        'message' => '{"msg":"as_json"}'
    }
    expected = {
        '@metadata' => {'beat' => 'heartbeat'},
        '@timestamp' => timestamp,
        'msg' => 'as_json'
    }

    now = Fluent::Engine.now
    d.run do
      client = create_client
      client.write(payload)
    end

    es = d.events
    assert_equal es[0][0], 'test.beats'
    assert_equal es.length, 1

    _tag, time, record = es[0]
    assert_in_delta now, time, 1.0
    assert_equal record["@timestamp"], timestamp
    assert_equal record, expected
  end
end
