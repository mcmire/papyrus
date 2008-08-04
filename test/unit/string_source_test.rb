require File.dirname(__FILE__)+'/test_helper'

require 'source'
require 'string_source'

Expectations do
  
  # StringSource#initialize
  begin
    # when options is a String
    expect "Some raw string" do
      source = PageTemplate::StringSource.new("Some raw string")
      source.send(:instance_variable_get, "@source")
    end
    # when options is not a string
    begin
      expect "Some raw string" do
        source = PageTemplate::StringSource.new(:source => "Some raw string")
        source.send(:instance_variable_get, "@source")
      end
      expect(:source => "Some raw string") do
        source = PageTemplate::StringSource.new(:source => "Some raw string")
        source.send(:instance_variable_get, "@options")
      end
    end
  end
  
  # StringSource#get
  expect "Some raw string" do
    source = PageTemplate::StringSource.new("")
    source.send(:instance_variable_set, "@source", "Some raw string")
    source.get
  end
  
end