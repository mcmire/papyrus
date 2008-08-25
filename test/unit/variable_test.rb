require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'command'
require 'variable'
require 'block_command'
require 'filter'

include Papyrus

Expectations do
  
  # Variable#initialize
  begin
    expect "foobar" do
      Variable.new(nil, "foobar", "").send(:instance_variable_get, "@name")
    end
    expect "[foo]" do
      Variable.new(nil, "", "[foo]").send(:instance_variable_get, "@raw_command")
    end
  end
  
  # Variable#output
  begin
    # when variable exists
    expect "some value" do
      var = Variable.new(nil, "", "")
      var.stubs(:parent).returns stub('parent', :get => "some value")
      var.output
    end
    # when variable doesn't exist
    expect "[foo]" do
      var = Variable.new(nil, "", "[foo]")
      var.stubs(:parent).returns stub('parent', :get => nil)
      var.output
    end
    # value converted to string
    expect "2" do
      var = Variable.new(nil, "", "")
      var.stubs(:parent).returns stub('parent', :get => 2)
      var.output
    end
  end
  
  # Variable#to_s
  expect "[ Variable: foobar ]" do
    Variable.new(nil, "foobar", "").to_s
  end
  
end