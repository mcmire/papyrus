require File.dirname(__FILE__)+'/test_helper'

require 'node'
require 'node_list'
require 'text'
require 'command'

include Papyrus

Expectations do
  
  expect [] do
    NodeList.new.send(:instance_variable_get, "@nodes")
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:length) do
      block.length
    end
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:size) do
      block.size
    end
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:first) do
      block.first
    end
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:last) do
      block.last
    end
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:empty?) do
      block.empty?
    end
  end
  
  locally do
    block = NodeList.new
    expect block.nodes.to.receive(:[]).with(0) do
      block[0]
    end
  end
  
  # Block#add
  begin
    # when argument is not a Command
    expect TypeError do
      NodeList.new.add("something else")
    end
    # when argument is a Command
    expect true do
      block = NodeList.new
      cmd = Command.new("", [])
      block.add(cmd)
      block.nodes.include?(cmd)
    end
  end
  
  locally do
    expect NodeList.new.to.receive(:add) do |block|
      block << "blah"
    end
  end
  
  expect "foobar" do
    block = NodeList.new
    block << Text.new("foo")
    block << Text.new("bar")
    block.output
  end
  
  expect "[ NodeList: [foo] [bar] ]" do
    block = NodeList.new
    block << Text.new("foo")
    block << Text.new("bar")
    block.to_s
  end
    
  
end