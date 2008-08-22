require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'variable'
require 'block_command'
require 'commands/filter'

include Papyrus

Expectations do
  
  # Value#initialize
  begin
    expect "foobar" do
      value = Variable.new("foobar", "unescaped")
      value.send(:instance_variable_get, "@name")
    end
    expect "unescaped" do
      value = Variable.new("foobar", "unescaped")
      value.send(:instance_variable_get, "@processor")
    end
  end
  
  # Value#output
  expect Commands::Filter.to.receive(:filter).with(:context, "unescaped", Variable) do |filter|
    value = Variable.new("", "unescaped")
    value.output(:context)
  end
  
  # Value#to_s
  begin
    # when @processor present
    expect "[ Variable: foobar :unescaped ]" do
      value = Variable.new("foobar", "unescaped")
      value.to_s
    end
    # when @processor blank
    expect "[ Variable: foobar ]" do
      value = Variable.new("foobar", "")
      value.to_s
    end
  end
  
end