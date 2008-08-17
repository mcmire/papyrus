require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'node_list'
require 'command'
require 'commands/comment'

Expectations do
  
  expect "This is a comment" do
    comment = Papyrus::Commands::Comment.new("", ["This is a comment"])
    comment.send(:instance_variable_get, "@comment")
  end
  
  expect "" do
    comment = Papyrus::Commands::Comment.new("", ["This is a comment"])
    comment.output
  end
  
  expect "[ Comment: This is a comment ]" do
    comment = Papyrus::Commands::Comment.new("", ["This is a comment"])
    comment.to_s
  end
  
end