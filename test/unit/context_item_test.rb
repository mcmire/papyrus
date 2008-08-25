require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'block_command'
require 'parser'

module Papyrus
  class ContextItemWrapper
    include ContextItem
    attr_reader :parent
  end
end

module Papyrus
  module Commands
    class SomeBlockCommand < BlockCommand
    end
  end
end

include Papyrus

Expectations do
  
  # #reset_context
  begin
    expect Hash.new do
      context_item = ContextItemWrapper.new
      context_item.reset_context
      context_item.vars
    end
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.reset_context
      context_item.object
    end
  end
  
  # #set
  begin
    # when key is a string
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.set("foo", "bar")
      context_item.send(:vars)['foo']
    end
    # when key is a symbol
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.set(:foo, "bar")
      context_item.send(:vars)['foo']
    end
  end
  
  # ContextItem#get
  begin
    # when key starts with a number
    expect "342skfdlf" do
      ContextItemWrapper.new.get("342skfdlf")
    end
    # when key is symbol
    expect ContextItemWrapper.new.to.receive(:get_primary_part).with('foo', 'foo') do |context_item|
      context_item.get(:foo)
    end
    # when only one key part
    begin
      expect "bar" do
        context_item = ContextItemWrapper.new
        context_item.stubs(:get_primary_part).returns("bar")
        context_item.get("foo")
      end
      expect ContextItemWrapper.new.to.receive(:get_secondary_part).never do |context_item|
        context_item.get("foo")
      end
    end
    # when multiple parts
    begin
      expect "baz" do
        context_item = ContextItemWrapper.new
        context_item.stubs(:get_primary_part).returns('bar' => 'baz')
        context_item.stubs(:get_secondary_part).returns("baz")
        context_item.get("foo.bar")
      end
      expect ContextItemWrapper.new.to.receive(:get_secondary_part).with("foo.bar", "bar", 'bar' => 'baz') do |context_item|
        context_item.stubs(:get_primary_part).returns('bar' => 'baz')
        context_item.get("foo.bar")
      end
    end
    # when get_primary_part returns nil
    expect ContextItemWrapper.new.to.receive(:get_secondary_part).never do |context_item|
      context_item.stubs(:get_primary_part).returns(nil)
      context_item.get("foo")
    end
  end
  
  # ContextItem#get_primary_part
  begin
    # when @vars has key
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, 'foo' => 'bar')
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars has key (as symbol)
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, :foo => 'bar')
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key and @object undefined, but parent has value
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.stubs(:parent).returns(:parent)
      context_item.stubs(:parent_get).returns('bar')
      context_item.send(:vars=, {})
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, @object undefined, @parent undefined
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.stubs(:parent).returns(nil)
      context_item.send(:vars=, {})
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, but @object has key
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns('foo' => 'bar')
       context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, and @object doesn't have key, but parent has key
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns({})
      context_item.stubs(:parent).returns(:parent)
      context_item.stubs(:parent_get).returns('bar')
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, @object doesn't have key, @parent undefined
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns({})
      context_item.stubs(:parent).returns(nil)
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, @object doesn't have key or isn't a hash,
    # but key is a method of object
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns stub('object', :foo => "bar")
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, @object doesn't have key, key is not a method of object,
    # but key is '__ITEM__'
    #expect Mocha::Mock do
    #  context_item = ContextItemWrapper.new
    #  context_item.send(:vars=, {})
    #  context_item.stubs(:object).returns stub('object')
    #  context_item.send(:get_primary_part, '__ITEM__', '__ITEM__')
    #end
    # when @vars doesn't have key, @object doesn't have key, key is not a method of object,
    # key is not '__ITEM__', but @parent defined
    expect "bar" do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns stub('object')
      context_item.stubs(:parent).returns(:parent)
      context_item.stubs(:parent_get).returns('bar')
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
    # when @vars doesn't have key, @object doesn't have key, key is not a method of object,
    # key is not '__ITEM__', @parent not defined
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, {})
      context_item.stubs(:object).returns stub('object')
      context_item.stubs(:parent).returns(nil)
      context_item.send(:get_primary_part, 'foo', 'foo')
    end
  end
  
  # #get_secondary_part when only one other secondary method call
  begin
    # #get_secondary_part if @vars has key
    expect 'baz' do
      context_item = ContextItemWrapper.new
      context_item.send(:vars=, 'foo.bar' => 'baz')
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', nil)
    end
    # #get_secondary_part when @vars doesn't have key, but value_so_far is a hash
    expect 'baz' do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', { 'bar' => 'baz' })
    end
    # #get_secondary_part when @vars doesn't have key, but value_so_far is an array
    expect 'baz' do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.1', '1', [ 'quux', 'baz' ])
    end
    # #get_secondary_part when @vars doesn't have key, but value_so_far is an object and key is a method
    expect 'baz' do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', stub("foo", :bar => 'baz'))
    end
    # #get_secondary_part when @vars doesn't have key, and key is not a method
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', stub("foo", :quux => 'baz'))
    end
    # #get_secondary_part when @vars doesn't have key and value_so_far is nil
    expect nil do
      context_item = ContextItemWrapper.new
      context_item.send(:get_secondary_part, 'foo.bar', 'bar', nil)
    end
  end
  
  # parent_get
  begin
    # when parent is a BlockCommand
    expect Commands::SomeBlockCommand.new(nil, "", []).to.receive(:_get) do |parent|
      context_item = ContextItemWrapper.new
      context_item.stubs(:parent).returns(parent)
      context_item.send(:parent_get, "")
    end
    # when parent is not a BlockCommand
    expect stub('parent').to.receive(:get) do |parent|
      context_item = ContextItemWrapper.new
      context_item.stubs(:parent).returns(parent)
      context_item.send(:parent_get, "")
    end
  end
  
  # #delete
  expect({}) do
    context_item = ContextItemWrapper.new
    context_item.send(:vars=, 'foo' => 'bar')
    context_item.delete('foo')
    context_item.send(:vars)
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
  
  # #true?
  begin
    # when get returns true-ish value
    expect true do
      context_item = ContextItemWrapper.new
      context_item.stubs(:get).returns("foo")
      context_item.true?("")
    end
    # when get returns false-ish value
    expect false do
      context_item = ContextItemWrapper.new
      context_item.stubs(:get).returns(nil)
      context_item.true?("")
    end
  end
  
  # #vars when @vars not defined
  expect({}) do
    context_item = ContextItemWrapper.new
    context_item.send(:vars)
  end
  # #vars when @vars defined
  expect(:foo => 'bar') do
    context_item = ContextItemWrapper.new
    context_item.send(:instance_variable_set, "@vars", :foo => 'bar')
    context_item.send(:vars)
  end
  
end