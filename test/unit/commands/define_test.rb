require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'node_list'
require 'command'
require 'commands/define'

Expectations do
  
  begin
    expect "foo" do
      define = Papyrus::Commands::Define.new("", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_name")
    end
    expect "bar" do
      define = Papyrus::Commands::Define.new("", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_value")
    end
  end
  
  begin
    expect "" do
      define = Papyrus::Commands::Define.new("", ["foo", "bar"])
      define.output({})
    end
    expect "bar" do
      define = Papyrus::Commands::Define.new("", ["foo", "bar"])
      context = {}
      define.output(context)
      context["foo"]
    end
  end
  
end