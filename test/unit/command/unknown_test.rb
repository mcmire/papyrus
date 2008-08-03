require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/unknown'

Expectations do
  
  expect "foo bar" do
    unknown = PageTemplate::Command::Unknown.new("foo bar")
    unknown.send(:instance_variable_get, "@raw_command")
  end
  
  expect stub('lexicon').to.receive(:lookup).with("foo bar") do |lexicon|
    unknown = PageTemplate::Command::Unknown.new("foo bar")
    unknown.lookup stub('context', :parser => stub('parser', :lexicon => lexicon))
  end
  
  begin
    expect "[ Unknown Command: foo bar ]" do
      unknown = PageTemplate::Command::Unknown.new("foo bar")
      unknown.stubs(:lookup).returns PageTemplate::Command::Unknown.new("")
      unknown.output(nil)
    end
    expect PageTemplate::Command::Base.new.to.receive(:output) do |cmd|
      unknown = PageTemplate::Command::Unknown.new("")
      unknown.stubs(:lookup).returns(cmd)
      unknown.output(nil)
    end
  end
  
  expect "[ Command::Unknown: foo bar ]" do
    unknown = PageTemplate::Command::Unknown.new("foo bar")
    unknown.to_s
  end
  
end