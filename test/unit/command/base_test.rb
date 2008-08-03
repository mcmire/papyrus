require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'

Expectations do
  
  expect NotImplementedError do
    PageTemplate::Command::Base.new.output
  end
  
  expect "[ PageTemplate::Command::Base ]" do
    PageTemplate::Command::Base.new.to_s
  end
  
end