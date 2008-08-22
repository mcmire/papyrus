require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'variable'
require 'block_command'
require 'filter'

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
      value.send(:instance_variable_get, "@filter")
    end
  end
  
  # Value#output
  expect Filter.to.receive(:filter).with("unescaped", "Some text") do
    context = stub("context", :get => "Some text")
    Variable.new("", "unescaped").output(context)
  end
  
  # Value#to_s
  begin
    # when @filter present
    expect "[ Variable: foobar :unescaped ]" do
      value = Variable.new("foobar", "unescaped")
      value.to_s
    end
    # when @filter blank
    expect "[ Variable: foobar ]" do
      value = Variable.new("foobar", "")
      value.to_s
    end
  end
  
end