require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/include'

Expectations do
  
  # Include#initialize
  expect "foo" do
    include_cmd = Papyrus::Command::Include.new(nil, "", "foo")
    include_cmd.send(:instance_variable_get, "@value")
  end
  
  # Include#output
  begin
    expect "Output of template" do
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      include_cmd.stubs(:get_template_from_value).returns([ '', stub('template', :output => "Output of template") ])
      include_cmd.output(nil)
    end
    expect "[ Template 'foo' not found ]" do
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      include_cmd.stubs(:get_template_from_value).returns([ "foo", nil ])
      include_cmd.output(nil)
    end
  end
  
  # Include#get_template_from_value
  begin
    # template is nil
    expect ["foo", nil] do
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      include_cmd.stubs(:get_compiled_or_uncompiled_template).returns(["foo", nil])
      include_cmd.send(:get_template_from_value, nil)
    end
    # template is not nil, but is a Command
    locally do
      cmd = Papyrus::Command::Base.new
      expect ["foo", cmd] do
        include_cmd = Papyrus::Command::Include.new(nil, "", "")
        include_cmd.stubs(:get_compiled_or_uncompiled_template).returns(["foo", cmd])
        include_cmd.send(:get_template_from_value, nil)
      end
    end
    # template is not nil and is not a Command
    expect ["foo", :compiled_template] do
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      include_cmd.stubs(:get_compiled_or_uncompiled_template).returns([ "foo", stub('cmd') ])
      include_cmd.stubs(:compile_template).returns(:compiled_template)
      include_cmd.send(:get_template_from_value, nil)
    end
  end
  
  # Include#get_compiled_or_uncompiled_template
  begin
    # when given value is a filename
    expect stub('source').to.receive(:get).with("some_file.txt") do |source|
      include_cmd = Papyrus::Command::Include.new(nil, "", "some_file.txt")
      include_cmd.send(:get_compiled_or_uncompiled_template, stub('context', :parser => stub('parser', :source => source), :get => nil))
    end
    # when given value is not a filename
    expect stub('context', :parser => stub('parser', :source => stub('source', :get => nil))).to.receive(:get).with("foo") do |context|
      include_cmd = Papyrus::Command::Include.new(nil, "", "foo")
      include_cmd.send(:get_compiled_or_uncompiled_template, context)
    end
    # when given value is a variable in the given context
    expect stub('source').to.receive(:get).times(2) do |source|
      include_cmd = Papyrus::Command::Include.new(nil, "", "foo")
      include_cmd.send(:get_compiled_or_uncompiled_template, stub('context', :parser => stub('parser', :source => source), :get => "some_file.txt"))
    end
  end
  
  # Include#compile_template
  begin
    # parser.parse is called
    expect stub('parser').to.receive(:parse).with("Some content") do |parser|
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      parser.stubs(:source).returns stub('source', :cache => nil)
      include_cmd.send(:compile_template, stub('context', :parser => parser), "foo", "Some content")
    end
    # parser.source.cache is called
    expect stub('source').to.receive(:cache).with("foo", :template) do |source|
      include_cmd = Papyrus::Command::Include.new(nil, "", "")
      context = stub('context', :parser => stub('parser', :parse => :template, :source => source))
      include_cmd.send(:compile_template, context, "foo", "")
    end
  end
  
end