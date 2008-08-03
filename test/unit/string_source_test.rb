require File.dirname(__FILE__)+'/test_helper'

require 'source'
require 'string_source'

Expectations do
  
  expect "Some raw string" do
    source = PageTemplate::StringSource.new("Some raw string")
    source.send(:instance_variable_get, "@source")
  end
  
  expect "Some raw string" do
    source = PageTemplate::StringSource.new("Some raw string")
    source.get
  end
  
end