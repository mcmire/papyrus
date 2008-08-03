require File.dirname(__FILE__)+'/test_helper'

require 'command/base'
require 'command/block'
require 'command/text'
require 'context_item'
require 'context'
require 'template'

Expectations do
  
  # Template#initialize
  expect "whatever" do
    template = PageTemplate::Template.new("whatever")
    template.send(:instance_variable_get, "@parser")
  end
  
  # Template#parent
  expect true do
    template = PageTemplate::Template.new(nil)
    template.parent.equal?(template)
  end
  
  # Template#output
  begin
    # when object is nil
    begin
      # @parent should be set to @parser
      expect "parser" do
        template = PageTemplate::Template.new("parser")
        template.class.superclass.any_instance.stubs(:output)
        template.output(nil)
        template.send(:instance_variable_get, "@parent")
      end
      # super(self) should be called
      locally do
        template = PageTemplate::Template.new("parser")
        expect template.class.superclass.any_instance.to.receive(:output).with(template) do
          template.output(nil)
        end
      end
    end
    # when object is a ContextItem
    begin
      # @parent should be set to object
      expect PageTemplate::Context do
        template = PageTemplate::Template.new("parser")
        template.class.superclass.any_instance.stubs(:output)
        template.output(PageTemplate::Context.new)
        template.send(:instance_variable_get, "@parent")
      end
      # super(self) should be called
      locally do
        template = PageTemplate::Template.new("parser")
        expect template.class.superclass.any_instance.to.receive(:output).with(template) do
          template.output(PageTemplate::Context.new)
        end
      end
    end
    # when object is not nil and not a ContextItem: super(instance of Context) should be called
    locally do
      template = PageTemplate::Template.new("parser")
      expect template.class.superclass.any_instance.to.receive(:output) do#.with(PageTemplate::Context.any_instance) do
        template.output("something else")
      end
    end
  end
  
  # Template#to_s
  expect "[ Template: [[ Blocks:  ]] [blah] ]" do
    template = PageTemplate::Template.new("parser")
    template << PageTemplate::Command::Block.new
    template << PageTemplate::Command::Text.new("blah")
    template.to_s
  end
  
end