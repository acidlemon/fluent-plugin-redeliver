# -*- coding: utf-8 -*-
require 'helper'

class RedeliverOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::RedeliverOutput, tag).configure(conf)
  end

  def test_configure
    d = create_driver %[
      regexp ^app\\.(.*)\\.(.*)$
      replace test.hoge.\\1_\\2
    ]
    
    assert_equal '^app\.(.*)\.(.*)$', d.instance.regexp
    assert_equal 'test.hoge.\1_\2', d.instance.replace
  end

  def test_emit
    d = create_driver %[
      regexp ^app\\.(.*)\\.(.*)$
      replace test.hoge.\\1_\\2
    ], 'app.foo.bar'

    now1 = Time.now
    now2 = Time.now + 100

    d.run do
      d.emit({ "test" => "value1" }, now1)
      d.emit({ "test" => "value2" }, now2)
    end

    emits = d.emits

    assert_equal 2, emits.length

    assert_equal 'test.hoge.foo_bar', emits[0][0]
    assert_equal now1.to_i, emits[0][1]
    assert_equal 'value1', emits[0][2]['test']
    assert_equal nil, emits[0][2]['tag']

    assert_equal 'test.hoge.foo_bar', emits[1][0]
    assert_equal now2.to_i, emits[1][1]
    assert_equal 'value2', emits[1][2]['test']
    assert_equal nil, emits[1][2]['tag']
  end

end
