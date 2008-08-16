require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/value'
require 'command/stackable'
require 'command/filter'

Expectations do
  
  # Value#initialize
  begin
    expect "foobar" do
      value = Papyrus::Variable.new("foobar", "unescaped")
      value.send(:instance_variable_get, "@value")
    end
    expect "unescaped" do
      value = Papyrus::Variable.new("foobar", "unescaped")
      value.send(:instance_variable_get, "@processor")
    end
  end
  
  # Value#output
  expect Papyrus::Command::Filter.to.receive(:filter).with(:context, "unescaped", Papyrus::Command::Value) do |filter|
    value = Papyrus::Variable.new("", "")
    value.send(:instance_variable_set, "@processor", "unescaped")
    value.output(:context)
  end
  
  # Value#to_s
  begin
    # when @processor present
    expect "[ Value: foobar :unescaped ]" do
      value = Papyrus::Variable.new("", "")
      value.send(:instance_variable_set, "@value", "foobar")
      value.send(:instance_variable_set, "@processor", "unescaped")
      value.to_s
    end
    # when @processor nil
    expect "[ Value: foobar ]" do
      value = Papyrus::Variable.new("", "")
      value.send(:instance_variable_set, "@value", "foobar")
      value.send(:instance_variable_set, "@processor", "")
      value.to_s
    end
  end
  
end