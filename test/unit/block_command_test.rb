require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'block_command'

include Papyrus

class BlockCommandChild < Papyrus::BlockCommand
end

module Papyrus
  module Commands
    class SomeBlockCommand < BlockCommand
      def active_block; :active_block; end
    end
  end
end

Expectations do
  
  # BlockCommand#initialize
  expect TypeError do
    BlockCommand.new(nil, "", [])
  end
  
  # BlockCommand#add
  expect NotImplementedError do
    BlockCommandChild.new(nil, "", []) << nil
  end
  
  # BlockCommand#active_block
  begin
    expect NotImplementedError do
      BlockCommandChild.new(nil, "", []).active_block
    end
    expect :active_block do
      Commands::SomeBlockCommand.new(nil, "", []).active_block
    end
  end
  
  # BlockCommand#add
  begin
    expect :command do
      cmd = Commands::SomeBlockCommand.new(nil, "", [])
      active_block = []
      cmd.stubs(:active_block).returns(active_block)
      cmd << :command
      active_block.last
    end
  end
  
  # BlockCommand#get
  begin
    expect stub('active_block').to.receive(:get) do |active_block|
      cmd = Commands::SomeBlockCommand.new(nil, "", [])
      cmd.stubs(:active_block).returns(active_block)
      cmd.get("")
    end
  end
  
  # BlockCommand#to_s
  expect "[ whatever ]" do
    cmd = BlockCommandChild.new(nil, "", [])
    cmd.send(:instance_variable_set, "@name", "whatever")
    cmd.to_s
  end
  
end