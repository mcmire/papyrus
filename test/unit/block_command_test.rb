require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'block_command'

include Papyrus

class BlockCommandChild < Papyrus::BlockCommand
  def initialize
  end
end

Expectations do
  
  expect ArgumentError do
    BlockCommand.new("", [])
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