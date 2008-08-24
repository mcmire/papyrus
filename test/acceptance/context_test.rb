require File.dirname(__FILE__)+'/test_helper'

require 'papyrus'

include Papyrus

require 'commands/if'

Expectations do
  
  expect 'bar' do
    template = Template.new(nil)
    if_cmd = Commands::If.new(template, "if", [])
    if_cmd.vars = { 'foo' => 'bar' }
    if_cmd2 = Commands::If.new(if_cmd, "if", [])
    if_cmd << if_cmd2
    if_cmd2.active_block.get('foo')
  end
  
end