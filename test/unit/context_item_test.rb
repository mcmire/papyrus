require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'parser'

include Papyrus

module Papyrus
  class ContextItemWrapper
    include ContextItem
  end
end

Expectations do
  
  # #clear/#clear_cache
  for method in %w(clear clear_cache)
    expect Hash.new do
      context_item = ContextItemWrapper.new
      context_item.send(method)
      context_item.send(:values)
    end
  end
  
  # #set
  begin
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.set("foo", "bar")
      context_item.send(:values)['foo']
    end
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.set(:foo, "bar")
      context_item.send(:values)['foo']
    end
  end
  
  # #get when key is symbol
  expect ContextItemWrapper.new.to.receive(:get_primary_part).with('foo', 'foo') do |context_item|
    context_item.stubs(:parser).returns stub("parser",
      :options => {}
    )
    context_item.get(:foo)
  end
  # #get when only one key part
  expect "bar" do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub("parser",
      :options => {}
    )
    context_item.stubs(:get_primary_part).returns("bar")
    context_item.get("foo")
  end
  # #get when multiple parts, but get_primary_part returns a value and 'true'
  expect "baz" do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub("parser",
      :options => {}
    )
    context_item.stubs(:get_primary_part).returns(["baz", true])
    context_item.get("foo.bar")
  end
  # #get when multiple parts
  expect "baz" do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub("parser",
      :options => {}
    )
    context_item.stubs(:get_primary_part).returns('bar' => 'baz')
    context_item.stubs(:get_secondary_part).returns("baz")
    context_item.get("foo.bar")
  end
  # #get when error is raised during method
  #expect "[ Error: ]" do
  #  context_item = ContextItemWrapper.new
  #  context_item.stubs(:parser).returns stub("parser",
  #    :options => {},
  #    :method_separator_regexp => %r|[./]|
  #  )
  #  # ...
  #end
  
  # #get_primary_part when @values has key
  expect "bar" do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser',
      :options => { 'raise_on_error' => false }
    )
    context_item.send(:values=, 'foo' => 'bar')
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values has key (as symbol)
=begin
  expect "bar" do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, :foo => 'bar')
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
=end
  # #get_primary_part when @values doesn't have key and @object undefined, but parent has value
  expect "bar" do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parent).returns stub('parent', :get => 'bar')
    context_item.send(:values=, {})
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, @object undefined, @parent undefined
  expect nil do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parent).returns(nil)
    context_item.send(:values=, {})
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, but @object has key
  expect ["bar", "bar"] do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns('foo' => 'bar')
    [ context_item.send(:get_primary_part, 'foo', 'foo'), context_item.send(:values)['foo'] ]
  end
  # #get_primary_part when @values doesn't have key, and @object doesn't have key, but parent has key
  expect ["bar", true] do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns({})
    context_item.stubs(:parent).returns stub('parent', :get => 'bar')
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, @object doesn't have key, @parent undefined
  expect nil do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns({})
    context_item.stubs(:parent).returns(nil)
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, @object doesn't have key or isn't a hash,
  # but key is a method of object
  expect "bar" do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns stub('object', :foo => "bar")
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, @object doesn't have key, key is not a method of object,
  # but key is '__ITEM__'
  expect Mocha::Mock do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns stub('object')
    context_item.send(:get_primary_part, '__ITEM__', '__ITEM__')
  end
  # #get_primary_part when @values doesn't have key, @object doesn't have key, key is not a method of object,
  # key is not '__ITEM__', but @parent defined
  expect ["bar", true] do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns stub('object')
    context_item.stubs(:parent).returns stub('parent', :get => 'bar')
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  # #get_primary_part when @values doesn't have key, @object doesn't have key, key is not a method of object,
  # key is not '__ITEM__', @parent not defined
  expect nil do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, {})
    context_item.stubs(:object).returns stub('object')
    context_item.stubs(:parent).returns(nil)
    context_item.send(:get_primary_part, 'foo', 'foo')
  end
  
  # #get_secondary_part when only one other secondary method call
  begin
    # #get_secondary_part if @values has key
    expect ['baz', 'baz'] do
      context_item = ContextItemWrapper.new
      context_item.send(:values=, 'foo.bar' => 'baz')
      ret = context_item.send(:get_secondary_part, 'foo.bar', 'bar', nil)
      [ ret, context_item.send(:values)['foo.bar'] ]
    end
    # #get_secondary_part when @values doesn't have key, but value_so_far is a hash
    expect ['baz', 'baz'] do
      context_item = ContextItemWrapper.new
      ret = context_item.send(:get_secondary_part, 'foo.bar', 'bar', { 'bar' => 'baz' })
      [ ret, context_item.send(:values)['foo.bar'] ]
    end
    # #get_secondary_part when @values doesn't have key, but value_so_far is an array
    expect ['baz', 'baz'] do
      context_item = ContextItemWrapper.new
      ret = context_item.send(:get_secondary_part, 'foo.1', '1', [ 'quux', 'baz' ])
      [ ret, context_item.send(:values)['foo.1'] ]
    end
    # #get_secondary_part when @values doesn't have key, but value_so_far is an object and key is a method
    expect ['baz', 'baz'] do
      context_item = ContextItemWrapper.new
      ret = context_item.send(:get_secondary_part, 'foo.bar', 'bar', stub("foo", :bar => 'baz'))
      [ ret, context_item.send(:values)['foo.bar'] ]
    end
    # #get_secondary_part when @values doesn't have key, and key is not a method
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', stub("foo", :quux => 'baz'))
    end
    # #get_secondary_part when @values doesn't have key and value_so_far is nil
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', nil)
    end
  end
  
  # #delete
  expect({}) do
    context_item = ContextItemWrapper.new
    context_item.send(:values=, 'foo' => 'bar')
    context_item.delete('foo')
    context_item.send(:values)
  end
  
  # #parser when #parent not nil
  expect :parser do
    context_item = ContextItemWrapper.new
    context_item.send(:instance_variable_set, "@parent", stub('parent', :parser => :parser))
    context_item.parser
  end
  # #parser when #parent nil
  expect :parser do
    context_item = ContextItemWrapper.new
    context_item.send(:instance_variable_set, "@parent", nil)
    context_item.send(:instance_variable_set, "@parser", :parser)
    context_item.parser
  end
  
  # #true? when given key doesn't exist
  expect false do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => {})
    context_item.stubs(:get).returns(nil)
    context_item.true?("")
  end
  # #true? when value is true
  expect true do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => {})
    context_item.stubs(:get).returns(true)
    context_item.true?("")
  end
  # #true? when value is not nil or false
  expect true do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => {})
    context_item.stubs(:get).returns("something")
    context_item.true?("")
  end
  # #true? when value is false
  expect false do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => {})
    context_item.stubs(:get).returns(false)
    context_item.true?("")
  end
  # #true? when parser.options[:empty_is_true] and value empty
  expect true do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => { :empty_is_true => true })
    context_item.stubs(:get).returns({})
    context_item.true?("")
  end
  # #true? when parser.options[:empty_is_true] and value not empty
  expect true do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => { :empty_is_true => true })
    context_item.stubs(:get).returns(:foo => 'bar')
    context_item.true?("")
  end
  # #true? when parser.options[:empty_is_true] not set and value empty
  expect false do
    context_item = ContextItemWrapper.new
    context_item.stubs(:parser).returns stub('parser', :options => {})
    context_item.stubs(:get).returns({})
    context_item.true?("")
  end
  
  # #values when @values not defined
  expect({}) do
    context_item = ContextItemWrapper.new
    context_item.send(:values)
  end
  # #values when @values defined
  expect(:foo => 'bar') do
    context_item = ContextItemWrapper.new
    context_item.send(:instance_variable_set, "@values", :foo => 'bar')
    context_item.send(:values)
  end
  
end