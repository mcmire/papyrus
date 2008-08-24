require File.dirname(__FILE__)+'/test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'text'
require 'command'

include Papyrus

Expectations do
  
  expect [] do
    NodeList.new(nil).send(:instance_variable_get, "@nodes")
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:length) do
      block.length
    end
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:size) do
      block.size
    end
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:first) do
      block.first
    end
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:last) do
      block.last
    end
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:empty?) do
      block.empty?
    end
  end
  
  locally do
    block = NodeList.new(nil)
    expect block.nodes.to.receive(:[]).with(0) do
      block[0]
    end
  end
  
  # Block#add
  begin
    # when argument is not a Command
    expect TypeError do
      NodeList.new(nil).add("something else")
    end
    # when argument is a Command
    expect true do
      block = NodeList.new(nil)
      cmd = Command.new("", [])
      block.add(cmd)
      block.nodes.include?(cmd)
    end
  end
  
  locally do
    expect NodeList.new(nil).to.receive(:add) do |block|
      block << "blah"
    end
  end
  
  expect "foobar" do
    block = NodeList.new(nil)
    block << Text.new("foo")
    block << Text.new("bar")
    block.output
  end
  
  expect "[ NodeList: [foo] [bar] ]" do
    block = NodeList.new(nil)
    block << Text.new("foo")
    block << Text.new("bar")
    block.to_s
  end
    
  
end