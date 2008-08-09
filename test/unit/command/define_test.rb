require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/define'

Expectations do
  
  begin
    expect "foo" do
      define = PageTemplate::Command::Define.new(nil, "", "foo", "bar")
      define.send(:instance_variable_get, "@name")
    end
    expect "bar" do
      define = PageTemplate::Command::Define.new(nil, "", "foo", "bar")
      define.send(:instance_variable_get, "@value")
    end
  end
  
  begin
    expect nil do
      define = PageTemplate::Command::Define.new(nil, "", "foo", "bar")
      define.output({})
    end
    expect "bar" do
      define = PageTemplate::Command::Define.new(nil, "", "foo", "bar")
      context = {}
      define.output(context)
      context["foo"]
    end
  end
  
end