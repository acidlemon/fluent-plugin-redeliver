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
    assert_equal nil, d.instance.tag_attr

    d = create_driver %[
      regexp ^debug\\.(.*)$
      replace ignore.\\1
      tag_attr __tag
    ]
    
    assert_equal '^debug\.(.*)$', d.instance.regexp
    assert_equal 'ignore.\1', d.instance.replace
    assert_equal '__tag', d.instance.tag_attr

  end

  def test_emit
    # constants
    now1 = Time.now
    now2 = Time.now + 100

    # basic test
    d1 = create_driver %[
      regexp ^app\\.(.*)\\.(.*)$
      replace test.hoge.\\1_\\2
    ], 'app.foo.bar'

    d1.run do
      d1.emit({ "test" => "value1" }, now1)
      d1.emit({ "test" => "value2" }, now2)
    end

    emits = d1.emits

    assert_equal 2, emits.length

    assert_equal 'test.hoge.foo_bar', emits[0][0]
    assert_equal now1.to_i, emits[0][1]
    assert_equal 'value1', emits[0][2]['test']
    assert_equal nil, emits[0][2]['tag']
    assert_equal nil, emits[1][2]['__tag']

    assert_equal 'test.hoge.foo_bar', emits[1][0]
    assert_equal now2.to_i, emits[1][1]
    assert_equal 'value2', emits[1][2]['test']
    assert_equal nil, emits[1][2]['tag']
    assert_equal nil, emits[1][2]['__tag']

    # not match test
    d2 = create_driver %[
       regexp ^app\\.bar\\.(.*)$
       replace test.hoge.\\1
    ], 'app.foo.bar'

    d2.run do
      d2.emit({ "test" => "value1" }, now1)
    end

    emits2 = d2.emits

    assert_equal 0, emits2.length

    # match with tag
    d3 = create_driver %[
      regexp ^app\\.(.*)\\.(.*)$
      replace test.hoge.\\1_\\2
      tag_attr __tag
    ], 'app.foo.bar'

    d3.run do
      d3.emit({ "test" => "value1" }, now1)
    end

    emits = d3.emits

    assert_equal 1, emits.length

    assert_equal 'test.hoge.foo_bar', emits[0][0]
    assert_equal now1.to_i, emits[0][1]
    assert_equal 'value1', emits[0][2]['test']
    assert_equal nil, emits[0][2]['tag']
    assert_equal 'app.foo.bar', emits[0][2]['__tag']


    # empty regexp
    d4 = create_driver %[], 'debug.foo'

    d4.run do
      d4.emit({ "test" => "value" }, now1)
    end

    emits = d4.emits

    assert_equal 0, emits.length

  end

end
