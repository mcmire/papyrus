require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/text'
require 'command/comment'
require 'command/block'

Expectations do
  
  expect [] do
    Papyrus::Command::CommandBlock.new.send(:instance_variable_get, "@commands")
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:length) do
      block.length
    end
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:size) do
      block.size
    end
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:first) do
      block.first
    end
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:last) do
      block.last
    end
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:empty?) do
      block.empty?
    end
  end
  
  locally do
    block = Papyrus::Command::CommandBlock.new
    expect block.send(:commands).to.receive(:[]).with(0) do
      block[0]
    end
  end
  
  # Block#add
  begin
    # when argument is not a Command
    expect TypeError do
      Papyrus::Command::CommandBlock.new.add("something else")
    end
    # when argument is a Command
    expect true do
      block = Papyrus::Command::CommandBlock.new
      cmd = Papyrus::Command::Base.new
      block.add(cmd)
      block.send(:commands).include?(cmd)
    end
  end
  
  locally do
    expect Papyrus::Command::CommandBlock.new.to.receive(:add) do |block|
      block << "blah"
    end
  end
  
  expect "foobar" do
    block = Papyrus::Command::CommandBlock.new
    block << Papyrus::Text.new("foo")
    block << Papyrus::Text.new("bar")
    block.output
  end
  
  expect "[ Blocks: [foo] [bar] ]" do
    block = Papyrus::Command::CommandBlock.new
    block << Papyrus::Text.new("foo")
    block << Papyrus::Text.new("bar")
    block.to_s
  end
    
  
end