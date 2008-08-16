require File.dirname(__FILE__)+'/test_helper'

require 'node'
require 'command'
require 'text'

include Papyrus

Expectations do
  
  expect "Some text and stuff" do
    text = Text.new("Some text and stuff")
    text.send(:instance_variable_get, "@text")
  end
  
  expect "Some text and stuff" do
    text = Text.new("")
    text.send(:instance_variable_set, "@text", "Some text and stuff")
    text.output
  end
  
  expect "Some text and stuff" do
    text = Text.new("")
    text.send(:instance_variable_set, "@text", "Some text and stuff")
    text.to_s
  end
  
end