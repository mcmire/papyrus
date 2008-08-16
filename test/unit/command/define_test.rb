require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/define'

Expectations do
  
  begin
    expect "foo" do
      define = Papyrus::Command::Define.new("", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_name")
    end
    expect "bar" do
      define = Papyrus::Command::Define.new("", ["foo", "bar"])
      define.send(:instance_variable_get, "@var_value")
    end
  end
  
  begin
    expect "" do
      define = Papyrus::Command::Define.new("", ["foo", "bar"])
      define.output({})
    end
    expect "bar" do
      define = Papyrus::Command::Define.new("", ["foo", "bar"])
      context = {}
      define.output(context)
      context["foo"]
    end
  end
  
end