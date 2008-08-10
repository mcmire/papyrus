require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/comment'

Expectations do
  
  expect "This is a comment" do
    comment = Papyrus::Command::Comment.new(nil, "", "This is a comment")
    comment.send(:instance_variable_get, "@comment")
  end
  
  expect "" do
    comment = Papyrus::Command::Comment.new(nil, "", "This is a comment")
    comment.output
  end
  
  expect "[ Comment: This is a comment ]" do
    comment = Papyrus::Command::Comment.new(nil, "", "This is a comment")
    comment.to_s
  end
  
end