require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'node_list'
require 'command'
require 'context_item'
require 'block_command'
require 'commands/filter'
require 'filter'

include Papyrus

Expectations do
  
  # Filter#initialize
  begin
    expect "foo" do
      Commands::Filter.new("", ["foo"]).send(:instance_variable_get, "@filter")
    end
    expect [] do
      Commands::Filter.new("", []).send(:instance_variable_get, "@nodes")
    end
  end
  
  # Filter#add
  expect Command do
    filter = Commands::Filter.new("", [])
    filter << Command.new("", [])
    filter.nodes.last
  end
  
  # Filter#output
  expect Filter.to.receive(:filter).with("unescaped", Commands::Filter, "Here's the text") do
    filter = Commands::Filter.new("filter", ["unescaped"])
    filter.nodes.stubs(:inject).returns("Here's the text")
    filter.output(nil)
  end
  
end