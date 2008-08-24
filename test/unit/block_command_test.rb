require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'block_command'

include Papyrus

class BlockCommandChild < Papyrus::BlockCommand
end

Expectations do
  
  # BlockCommand#initialize
  expect ArgumentError do
    BlockCommand.new(nil, "", [])
  end
  
  # BlockCommand#add
  expect ArgumentError do
    BlockCommandChild.new(nil, "", []) << nil
  end
  
  # BlockCommand#to_s
  expect "[ whatever ]" do
    cmd = BlockCommandChild.new(nil, "", [])
    cmd.send(:instance_variable_set, "@name", "whatever")
    cmd.to_s
  end
  
end