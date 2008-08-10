require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/unknown'

Expectations do
  
  # Unknown#initialize
  expect "foo bar" do
    unknown = Papyrus::Command::Unknown.new(nil, "foo bar")
    unknown.send(:instance_variable_get, "@raw_command")
  end
  
  # Unknown#output
  begin
    expect "[ Unknown Command: foo bar ]" do
      unknown = Papyrus::Command::Unknown.new(nil, "foo bar")
      unknown.stubs(:lexicon).returns stub('lexicon', :lookup => Papyrus::Command::Unknown.new(nil, ""))
      unknown.output(nil)
    end
    expect Papyrus::Command::Base.new.to.receive(:output) do |cmd|
      unknown = Papyrus::Command::Unknown.new(nil, "")
      unknown.stubs(:lexicon).returns stub('lexicon', :lookup => cmd)
      unknown.output(nil)
    end
  end
  
  # Unknown#to_s
  expect "[ Command::Unknown: foo bar ]" do
    unknown = Papyrus::Command::Unknown.new(nil, "foo bar")
    unknown.to_s
  end
  
end