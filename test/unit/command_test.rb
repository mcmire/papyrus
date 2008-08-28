require File.dirname(__FILE__)+'/test_helper'

require 'node'
require 'command'
require 'context_item'
require 'block_command'

module Papyrus
  module Commands
    class Foo < BlockCommand
    end
  end
end

include Papyrus

Expectations do
  
  # Base.modifiers
  begin
    expect Set do
      Command.send(:instance_variable_set, "@modifiers", nil)
      Command.modifiers
    end
    expect Set.new(["foo", "bar"]) do
      Command.send(:instance_variable_set, "@modifiers", Set.new(["foo", "bar"]))
      Command.modifiers
    end
  end
  
  # Base.modifier
  begin
    expect true do
      Command.send(:instance_variable_set, "@modifiers", nil)
      Command.modifier(:foobarbaz) {}
      Command.instance_methods.include?("foobarbaz")
    end
    expect true do
      Command.send(:instance_variable_set, "@modifiers", nil)
      Command.modifier(:foobarbaz) {}
      Command.modifiers.include?(:foobarbaz)
    end
  end
  
  # Base.aliases
  begin
    expect Set.new do
      Command.send(:instance_variable_set, "@aliases", nil)
      Command.aliases
    end
    expect Set.new(["foo", "bar"]) do
      Command.send(:instance_variable_set, "@aliases", Set.new(["foo", "bar"]))
      Command.aliases
    end
  end
  
  # Base.aka
  begin
    expect true do
      Command.aka :foo
      Command.aliases.include?(:foo)
    end
  end
  
  # Base#initialize
  begin
    expect "foo" do
      Command.new(nil, "foo", []).send(:instance_variable_get, "@name")
    end
    expect ["bar", "baz"] do
      Command.new(nil, "foo", ["bar", "baz"]).send(:instance_variable_get, "@args")
    end
  end
  
  # Base#modified_by?
  begin
    # when command is not a BlockCommand
    expect false do
      Command.new(nil, "", []).modified_by?("", [])
    end
    # when does not respond_to?(modifier)
    expect false do
      foo = Commands::Foo.new(nil, "", [])
      foo.modified_by?("foo", [])
    end
    # when method returns false
    expect false do
      foo = Commands::Foo.new(nil, "", [])
      foo.stubs(:else).returns(false)
      foo.modified_by?("else", [])
    end
    # when method returns true
    expect true do
      foo = Commands::Foo.new(nil, "", [])
      foo.stubs(:else).returns(true)
      foo.modified_by?("else", [])
    end
  end
  
  # Base#output
  expect NotImplementedError do
    Command.new(nil, "", []).output
  end
  
  # Base#to_s
  expect "[ Papyrus::Command ]" do
    Command.new(nil, "", []).to_s
  end
  
end