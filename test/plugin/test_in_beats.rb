require 'fluent/test'
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
    Fluent::Test::InputTestDriver.new(Fluent::BeatsInput).configure(conf)
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

    tag, es = d.emit_streams[0]
    assert_equal tag, 'test.beats'
    assert_equal es.length, 1

    time, record = es[0]
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

    tag, es = d.emit_streams[0]
    assert_equal tag, 'heartbeat'
    assert_equal es.length, 1

    time, record = es[0]
    assert_equal time.to_i, Time.parse(timestamp).to_i
    assert_equal record, payload
  end
end
