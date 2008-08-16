require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/stackable'

module Papyrus
  module Command
    class Foo < BlockCommand
    end
  end
end

include Papyrus

Expectations do
  
  # Base.modifiers
  begin
    expect Set do
      Command::Base.send(:instance_variable_set, "@modifiers", nil)
      Command::Base.modifiers
    end
    expect Set.new(["foo", "bar"]) do
      Command::Base.send(:instance_variable_set, "@modifiers", Set.new(["foo", "bar"]))
      Command::Base.modifiers
    end
  end
  
  # Base.modifier
  begin
    expect true do
      Command::Base.send(:instance_variable_set, "@modifiers", nil)
      Command::Base.modifier(:foobarbaz) {}
      Command::Base.instance_methods.include?("foobarbaz")
    end
    expect true do
      Command::Base.send(:instance_variable_set, "@modifiers", nil)
      Command::Base.modifier(:foobarbaz) {}
      Command::Base.modifiers.include?(:foobarbaz)
    end
  end
  
  # Base#initialize
  begin
    expect "foo" do
      Command::Base.new("foo", []).send(:instance_variable_get, "@name")
    end
    expect ["bar", "baz"] do
      Command::Base.new("foo", ["bar", "baz"]).send(:instance_variable_get, "@args")
    end
  end
  
  # Base#modified_by?
  begin
    # when command is not a BlockCommand
    expect false do
      Command::Base.new("", []).modified_by?('')
    end
    # when not lexicon.modifier_on
    expect false do
      foo = Command::Foo.new("", [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => nil)
      foo.modified_by?('')
    end
    # when does not respond_to?(modifier)
    expect false do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:foo, match])
      foo.modified_by?('')
    end
    # when method returns false
    expect false do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:end, match])
      foo.stubs(:end).returns(false)
      foo.modified_by?('')
    end
    # when method returns true
    expect true do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:end, match])
      foo.stubs(:end).returns(true)
      foo.modified_by?("")
    end
  end
  
  # Base#closed_by?
  begin
    # when command is not a BlockCommand
    expect false do
      Command::Base.new("", []).closed_by?('')
    end
    # when not lexicon.closer_on
    expect false do
      foo = Command::Foo.new("", [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => nil)
      foo.closed_by?('')
    end
    # when does not respond_to? modifier
    expect false do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:foo, match])
      foo.closed_by?('')
    end
    # when method returns false
    expect false do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:end, match])
      foo.stubs(:end).returns(false)
      foo.closed_by?('')
    end
    # when method returns true
    expect true do
      foo = Command::Foo.new("", [])
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:end, match])
      foo.stubs(:end).returns(true)
      foo.closed_by?("")
    end
  end
  
  # Base#output
  expect NotImplementedError do
    Command::Base.new("", []).output
  end
  
  # Base#to_s
  expect "[ Papyrus::Command::Base ]" do
    Command::Base.new("", []).to_s
  end
  
end