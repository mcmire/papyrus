require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/text'

Expectations do
  
  expect "Some text and stuff" do
    text = Papyrus::Command::Text.new("Some text and stuff")
    text.send(:instance_variable_get, "@text")
  end
  
  expect "Some text and stuff" do
    text = Papyrus::Command::Text.new("")
    text.send(:instance_variable_set, "@text", "Some text and stuff")
    text.output
  end
  
  expect "Some text and stuff" do
    text = Papyrus::Command::Text.new("")
    text.send(:instance_variable_set, "@text", "Some text and stuff")
    text.to_s
  end
  
end