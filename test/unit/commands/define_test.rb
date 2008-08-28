require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'command'
require 'commands/define'
require 'context'

include Papyrus

Expectations do
  
  begin
    expect "foo" do
      define = Commands::Define.new(nil, "", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_name")
    end
    expect "bar" do
      define = Commands::Define.new(nil, "", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_value")
    end
  end
  
  begin
    expect "" do
      define = Commands::Define.new(nil, "", ["foo", "bar"])
      define.stubs(:parent).returns stub("parent", :set => nil)
      define.output
    end
    expect "bar" do
      define = Commands::Define.new(nil, "", ["foo", "bar"])
      parent = Context.new
      define.stubs(:parent).returns(parent)
      define.output
      parent["foo"]
    end
  end
  
end