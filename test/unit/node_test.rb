require File.dirname(__FILE__)+'/test_helper'

require 'node'

include Papyrus

Expectations do
  
  # Node#initialize
  begin
    # @parent
    expect :parent do
      Node.new(:parent).send(:instance_variable_get, "@parent")
    end
  end
  
  # Node#output
  begin
    # must be overridden
    expect NotImplementedError do
      Node.new.output
    end
  end
  
  # Node#to_s
  begin
    expect "[ Papyrus::Node ]" do
      Node.new.to_s
    end
  end
  
end