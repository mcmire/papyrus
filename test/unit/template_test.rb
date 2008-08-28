#
# FIXME when Template is a NodeList
#

require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'node'
require 'node_list'
require 'text'
require 'template'

include Papyrus

Expectations do
  
  # Template#initialize
  begin
    expect :parser do
      Template.new(:parser).send(:instance_variable_get, "@parser")
    end
    expect('foo' => 'bar') do
      Template.new(nil, 'foo' => 'bar').send(:instance_variable_get, "@vars")
    end
  end
  
  # Template#to_s
  expect "[ Template: [[ NodeList:  ]] [blah] ]" do
    template = Template.new("parser")
    template << NodeList.new(template)
    template << Text.new("blah")
    template.to_s
  end
  
end