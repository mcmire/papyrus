require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'command'
require 'block_command'
require 'commands/filter'
require 'filter'

include Papyrus

Expectations do
  
  # Filter#initialize
  begin
    expect "foo" do
      Commands::Filter.new(nil, "", ["foo"]).send(:instance_variable_get, "@filter")
    end
    expect [] do
      Commands::Filter.new(nil, "", []).send(:instance_variable_get, "@nodes")
    end
    expect [] do
      Commands::Filter.new(nil, "", []).send(:instance_variable_get, "@active_block")
    end
  end
  
  # Filter#output
  expect Filter.to.receive(:filter).with("unescaped", "Here's the text") do
    filter = Commands::Filter.new(nil, "filter", ["unescaped"])
    filter.nodes.stubs(:inject).returns("Here's the text")
    filter.output
  end
  
end