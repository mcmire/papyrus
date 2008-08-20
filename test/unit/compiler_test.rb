require File.dirname(__FILE__)+'/test_helper'

require 'papyrus'

include Papyrus

this_dir = File.dirname(__FILE__)

require 'tempfile'

Expectations do
  
  # Compiler.get_source_path
  begin
    # foil attempts to get around template paths restriction
    # (this is not a very good test)
    expect File.to.receive(:exists?).with("./foo/bar") do
      Compiler.get_source_path("../foo/bar")
    end
    # file is in template paths
    expect File.join(this_dir, "foo/bar") do
      File.stubs(:exists?).returns(true)
      Compiler.get_source_path("foo/bar")
    end
    # file is not in template paths
    expect nil do
      Compiler.get_source_path("foo/bar")
    end
  end
  
  # Compiler#initialize
  begin
    # @source_file
    expect "/foo/bar/baz.txt" do
      Compiler.stubs(:get_source_path).returns("/foo/bar/baz.txt")
      Papyrus.stubs(:compiled_template_dir).returns("")
      compiler = Compiler.new("")
      compiler.send(:instance_variable_get, "@source_file")
    end
    # template not found
    expect RuntimeError do
      Compiler.stubs(:get_source_path).returns(nil)
      Compiler.new("")
    end
    # @compiled_file
    expect "/foo/bar/baz.txt" do
      Compiler.stubs(:get_source_path).returns("/some/path")
      Compiler.stubs(:get_compiled_path).returns("/foo/bar/baz.txt")
      compiler = Compiler.new("")
      compiler.send(:instance_variable_get, "@compiled_file")
    end
  end
  
  # Compiler#compiled_file
  begin
    expect "/foo/bar/baz" do
      Papyrus.stubs(:compiled_template_dir).returns('/foo/bar')
      File.stubs(:basename).returns('baz')
      compiler = Compiler.new("")
      compiler.stubs(:get_source_path)
      compiler.compiled_file
    end
  end
  
  # Compiler#compile
  begin
    # compiled file does not exist
    expect Compiler.new("").to.receive(:compile_source_template) do |compiler|
      compiler.stubs(:source_file)
      compiler.stubs(:compiled_file)
      File.stubs(:exists?).returns(false)
      compiler.compile
    end
    # file exists, but file has been modified since being cached
    expect Compiler.new("").to.receive(:compile_source_template) do |compiler|
      compiler.stubs(:source_file)
      compiler.stubs(:compiled_file)
      File.stubs(:exists?).returns(true)
      compiler.stubs(:source_mtime).returns(2)
      compiler.stubs(:compiled_mtime).returns(1)
      compiler.compile
    end
    # file exists and file has not been modified since being cached
    expect Compiler.new("").to.receive(:get_compiled_template) do |compiler|
      compiler.stubs(:source_file)
      compiler.stubs(:compiled_file)
      File.stubs(:exists?).returns(true)
      compiler.stubs(:source_mtime).returns(1)
      compiler.stubs(:compiled_mtime).returns(2)
      compiler.compile
    end
  end
  
  # Compiler#get_compiled_template
  begin
    expect Template do
      template = Template.new(nil)
      data = Zlib::Deflate.deflate(Marshal.dump(template))
      tempfile = Tempfile.new("papyrus")
      tempfile.write(data)
      tempfile.close
      compiler = Compiler.new("")
      compiler.stubs(:compiled_file).returns(tempfile.path)
      compiler.get_compiled_template
    end
  end
  
  # Compiler#compile_source_template
  begin
    # returns a Template
    expect true do
      compiler = Compiler.new("")
      compiler.stubs(:source_file)
      compiler.stubs(:compiled_file)
      File.stubs(:open)
      template = Template.new("")
      Parser.stubs(:parse).returns(template)
      Zlib::Deflate.stubs(:deflate)
      ret = compiler.compile_source_template
      ret.equal?(template)
    end
    # template is cached
  end
  
end
  
  
=begin
  
  # Compiler.new
  begin
    expect(:foo => 'bar') do
      compiler = Compiler.new(:foo => 'bar')
      compiler.send(:instance_variable_get, "@options")
    end
    expect DefaultPreprocessor do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@preprocessor")
    end
    expect :unescaped do
      compiler = Compiler.new
      compiler.send(:instance_variable_get, "@default_processor")
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
    # when body is a instance of Command
    expect Command do
      compiler = Compiler.new
      compiler.source.stubs(:get).returns(Command.new("", []))
      compiler.compile("")
    end
    # when body is not an instance of Command
    expect Compiler.new.to.receive(:parse) do |compiler|
      compiler.source.stubs(:get).returns("some content")
      compiler.compile("")
    end
    # when body is nil
    expect [RuntimeError, "Template 'foo' not found!"] do
      compiler = Compiler.new
      compiler.source.stubs(:get).returns(nil)
      begin; compiler.compile("foo"); rescue => e; end
      [e.class, e.message]
    end
  end
  
  # Compiler#parse
  begin
    expect Parser.any_instance.to.receive(:parse) do
      compiler = Compiler.new
      compiler.source.stubs(:cache)
      compiler.parse("", "")
    end
    expect stub('source').to.receive(:cache).with("foo", :command) do |source|
      compiler = Compiler.new
      compiler.stubs(:source).returns(source)
      Parser.any_instance.stubs(:parse).returns(:command)
      compiler.parse("foo", "")
    end
    expect :template do
      compiler = Compiler.new
      compiler.source.stubs(:cache)
      Parser.any_instance.stubs(:parse).returns(:template)
      compiler.parse("", "")
    end
  end
  
  # Compiler#something
  begin
    # Template is not in file cache
    # Template is in file cache and file has not been modified since being cached
    # Template is in file cache, but file has been modified since being cached
  end
  
end
=end