require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/stackable'

class StackableChild < PageTemplate::Command::Stackable
  def initialize
  end
end

Expectations do
  
  expect ArgumentError do
    PageTemplate::Command::Stackable.new
  end
  
  expect ArgumentError do
    StackableChild.new << nil
  end
  
  expect "[ whatever ]" do
    stackable = StackableChild.new
    stackable.send(:instance_variable_set, "@called_as", "whatever")
    stackable.to_s
  end
  
end