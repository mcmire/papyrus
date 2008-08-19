#
# FIXME when Template is a NodeList
#

require File.dirname(__FILE__)+'/test_helper'

require 'node'
require 'node_list'
require 'command'
require 'block_command'
require 'text'
require 'context_item'
require 'context'
require 'template'

include Papyrus

Expectations do
  
  # Template#initialize
  begin
    expect :parser do
      template = Template.new(:parser)
      template.send(:instance_variable_get, "@parser")
    end
    expect nil do
      template = Template.new(:parser)
      template.send(:instance_variable_get, "@parent")
    end
  end
  
  # Template#output
  begin
    # when object is nil
    # super(self) should be called
    locally do
      template = Template.new("parser")
      expect template.class.superclass.any_instance.to.receive(:output).with(template) do
        template.output(nil)
      end
    end
    # when object is a ContextItem
    begin
      # @parent should be set to object
      expect Context do
        template = Template.new("parser")
        template.class.superclass.any_instance.stubs(:output)
        template.output(Context.new)
        template.send(:instance_variable_get, "@parent")
      end
      # super(self) should be called
      locally do
        template = Template.new("parser")
        expect template.class.superclass.any_instance.to.receive(:output).with(template) do
          template.output(Context.new)
        end
      end
    end
    # when object is not nil and not a ContextItem: super(instance of Context) should be called
    locally do
      template = Template.new("parser")
      expect template.class.superclass.any_instance.to.receive(:output) do#.with(Context.any_instance) do
        template.output("something else")
      end
    end
  end
  
  # Template#to_s
  expect "[ Template: [[ NodeList:  ]] [blah] ]" do
    template = Template.new("parser")
    template << NodeList.new
    template << Text.new("blah")
    template.to_s
  end
  
end