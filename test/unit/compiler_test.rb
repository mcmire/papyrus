require File.dirname(__FILE__)+'/test_helper'

require 'papyrus'

include Papyrus

Expectations do
  
  # Compiler.new
  begin
    expect(:foo => 'bar') do
      compiler = Compiler.new(:foo => 'bar')
      compiler.send(:instance_variable_get, "@options")
    end
    expect DefaultLexicon do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@lexicon")
    end
    expect DefaultPreprocessor do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@preprocessor")
    end
    expect :unescaped do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@default_processor")
    end
    expect %r|[./]| do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@method_separator_regexp")
    end
    begin
      expect FileSource do
        compiler = Compiler.new
        compiler.send(:instance_variable_get, "@source")
      end
      expect StringSource do
        compiler = Compiler.new(:source => StringSource)
        compiler.send(:instance_variable_get, "@source")
      end
    end
    expect nil do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@commands")
    end
  end
  
  # Compiler#load
  begin
    expect Compiler.new.to.receive(:compile).with("foo") do |compiler|
      compiler.load("foo")
    end
    expect :template do
      compiler = Compiler.new
      compiler.stubs(:compile).returns(:template)
      compiler.load("")
    end
  end
  
  # Compiler#compile
  begin
    #expect stub('source').to.receive(:get).with("foo").returns(:something) do |source|
    #  compiler = Compiler.new
    #  compiler.stubs(:source).returns(source)
    #  compiler.compile("foo")
    #end
    # when body is a instance of Command::Base
    expect Command::Base do
      compiler = Compiler.new
      compiler.source.stubs(:get).returns(Command::Base.new)
      compiler.compile("")
    end
    # when body is not an instance of Command::Base
    begin
      expect Parser.any_instance.to.receive(:parse) do#.with("some content", DefaultLexicon, nil) do
        compiler = Compiler.new
        compiler.source.stubs(:get).returns("some content")
        compiler.source.stubs(:cache)
        compiler.compile("")
      end
      expect stub('source').to.receive(:cache).with("foo", :command) do |source|
        compiler = Compiler.new
        source.stubs(:get).returns("")
        compiler.stubs(:source).returns(source)
        Parser.any_instance.stubs(:parse).returns(:command)
        compiler.compile("foo")
      end
      expect :template do
        compiler = Compiler.new
        compiler.source.stubs(:cache)
        Parser.any_instance.stubs(:parse).returns(:template)
        compiler.compile("")
      end
    end
    # when body is nil
    expect [RuntimeError, "Template 'foo' not found!"] do
      compiler = Compiler.new
      compiler.source.stubs(:get).returns(nil)
      begin; compiler.compile("foo"); rescue => e; end
      [e.class, e.message]
    end
  end
  
end