require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/stackable'

class BlockCommandChild < Papyrus::Command::BlockCommand
  def initialize
  end
end

Expectations do
  
  expect ArgumentError do
    Papyrus::Command::BlockCommand.new("", [])
  end
  
  expect ArgumentError do
    BlockCommandChild.new("", []) << nil
  end
  
  expect "[ whatever ]" do
    stackable = BlockCommandChild.new
    stackable.send(:instance_variable_set, "@name", "whatever")
    stackable.to_s
  end
  
end