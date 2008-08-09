require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/value'
require 'command/stackable'
require 'command/filter'

Expectations do
  
  # Value#initialize
  begin
    expect "foo bar" do
      value = PageTemplate::Command::Value.new(nil, "", "foo bar", :unescaped)
      value.send(:instance_variable_get, "@value")
    end
    expect :unescaped do
      value = PageTemplate::Command::Value.new(nil, "", "foo bar", :unescaped)
      value.send(:instance_variable_get, "@processor")
    end
  end
  
  # Value#output
  expect PageTemplate::Command::Filter.to.receive(:filter).with(:context, :unescaped, PageTemplate::Command::Value) do |filter|
    value = PageTemplate::Command::Value.new(nil, "", nil, nil)
    value.send(:instance_variable_set, "@processor", :unescaped)
    value.output(:context)
  end
  
  # Value#to_s
  begin
    # when @processor present
    expect "[ Value: foo bar :unescaped ]" do
      value = PageTemplate::Command::Value.new(nil, "", nil, nil)
      value.send(:instance_variable_set, "@value", "foo bar")
      value.send(:instance_variable_set, "@processor", :unescaped)
      value.to_s
    end
    # when @processor nil
    expect "[ Value: foo bar ]" do
      value = PageTemplate::Command::Value.new(nil, "", nil, nil)
      value.send(:instance_variable_set, "@value", "foo bar")
      value.send(:instance_variable_set, "@processor", nil)
      value.to_s
    end
  end
  
end