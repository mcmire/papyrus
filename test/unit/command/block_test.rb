require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/text'
require 'command/comment'
require 'command/block'

Expectations do
  
  expect [] do
    PageTemplate::Command::Block.new.send(:instance_variable_get, "@command_block")
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:length) do
      block.length
    end
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:size) do
      block.size
    end
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:first) do
      block.first
    end
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:last) do
      block.last
    end
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:empty?) do
      block.empty?
    end
  end
  
  locally do
    block = PageTemplate::Command::Block.new
    expect block.send(:command_block).to.receive(:[]).with(0) do
      block[0]
    end
  end
  
  # Block#add
  begin
    # when argument is not a Command
    expect TypeError do
      PageTemplate::Command::Block.new.add("something else")
    end
    # when argument is a Command
    expect true do
      block = PageTemplate::Command::Block.new
      cmd = PageTemplate::Command::Base.new
      block.add(cmd)
      block.send(:command_block).include?(cmd)
    end
  end
  
  locally do
    expect PageTemplate::Command::Block.new.to.receive(:add) do |block|
      block << "blah"
    end
  end
  
  expect "foobar" do
    block = PageTemplate::Command::Block.new
    block << PageTemplate::Command::Text.new("foo")
    block << PageTemplate::Command::Text.new("bar")
    block.output
  end
  
  expect "[ Blocks: [foo] [bar] ]" do
    block = PageTemplate::Command::Block.new
    block << PageTemplate::Command::Text.new("foo")
    block << PageTemplate::Command::Text.new("bar")
    block.to_s
  end
    
  
end