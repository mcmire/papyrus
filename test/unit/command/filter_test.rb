require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/stackable'
require 'command/filter'
require 'context_item'
require 'parser'

Expectations do
  
  # Filter.filter
  begin
    # when preprocessor.respond_to?(processor)
    begin
      expect PageTemplate::Command::Filter.to.receive(:filter).yields(:context) do |filter_klass|
        preprocessor = stub('preprocessor', :process => nil)
        #puts filter_klass.private_methods.include?('get_processing_components')
        #puts filter_klass.public_methods.include?('get_processing_components')
        filter_klass.stubs(:get_processing_components).returns([:context, preprocessor, :process])
        #puts filter_klass.private_methods.include?('get_processing_components')
        #puts filter_klass.public_methods.include?('get_processing_components')
        filter_klass.filter(nil, nil, nil) {|cxt| "" }
      end
      expect stub('preprocessor').to.receive(:process).with("This is some text") do |preprocessor|
        filter_klass = PageTemplate::Command::Filter
        filter_klass.stubs(:get_processing_components).returns([nil, preprocessor, :process])
        filter_klass.filter(nil, nil, nil) {|cxt| "This is some text" }
      end
    end
    # when not preprocessor.respond_to?(processor)
    expect "[ SomeClass: unknown preprocessor 'foo' in SomePreprocessor ]" do
      filter_klass = PageTemplate::Command::Filter
      filter_klass.stubs(:get_processing_components).returns([nil, 'SomePreprocessor', :foo])
      filter_klass.filter(nil, nil, 'SomeClass') { }
    end
  end
  
  # Filter.get_processing_components
  begin
    # assert get_context_and_parser is called?
    # assert parser.preprocessor is called?
    # when processor is nil
    expect :default_processor do
      filter_klass = PageTemplate::Command::Filter
      parser = stub('parser', :preprocessor => nil, :default_processor => :default_processor)
      filter_klass.stubs(:get_context_and_parser).returns([nil, parser])
      context, preprocessor, processor = filter_klass.get_processing_components(nil, nil)
      processor
    end
    # when processor is not nil
    expect :custom_processor do
      filter_klass = PageTemplate::Command::Filter
      parser = stub('parser', :preprocessor => nil)
      filter_klass.stubs(:get_context_and_parser).returns([nil, parser])
      context, preprocessor, processor = filter_klass.get_processing_components(nil, :custom_processor)
      processor
    end
  end
  
  # Filter.get_context_and_parser
  begin
    # when context is present
    expect :parser do
      filter_klass = PageTemplate::Command::Filter
      context = stub('context', :parser => :parser)
      context, parser = filter_klass.get_context_and_parser(context)
      parser
    end
    # when context is nil
    expect true do
      filter_klass = PageTemplate::Command::Filter
      PageTemplate::Parser.stubs(:recent_parser).returns(:parser)
      context, parser = filter_klass.get_context_and_parser(nil)
      parser == :parser && context == parser
    end
  end
  
  # Filter#initialize
  begin
    expect :foo do
      filter = PageTemplate::Command::Filter.new(nil, "", :foo)
      filter.send(:instance_variable_get, "@processor")
    end
    expect [] do
      filter = PageTemplate::Command::Filter.new(nil, "", nil)
      filter.send(:instance_variable_get, "@text")
    end
  end
  
  # Filter#add
  expect PageTemplate::Command::Base do
    filter = PageTemplate::Command::Filter.new(nil, "", nil)
    filter << PageTemplate::Command::Base.new
    filter.send(:instance_variable_get, "@text").last
  end
  
  # Filter#output
  expect PageTemplate::Command::Filter.to.receive(:filter).with(:context, :unescaped, PageTemplate::Command::Filter) do |filter_klass|
    filter = filter_klass.new(nil, "", nil)
    filter.send(:instance_variable_set, "@processor", :unescaped)
    filter.output(:context)
  end
  
end