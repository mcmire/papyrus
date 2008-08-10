require File.dirname(__FILE__)+'/test_helper'

require 'Papyrus'

# TODO: Should we convert @stack, @active_cmd, etc. to method calls?
# Setting the instance variable through a private mutator here is kind of unwieldy...

Expectations do
  
  # Parser.recent_parser
  begin
    # when @@recent_parser defined
    expect Mocha::Mock do
      Papyrus::Parser.send(:class_variable_set, "@@recent_parser", stub('parser'))
      Papyrus::Parser.recent_parser
    end
    # when @@recent_parser not defined
    expect nil do
      Papyrus::Parser.send(:class_variable_set, "@@recent_parser", nil)
      Papyrus::Parser.recent_parser
    end
  end
  
  # Parser.new
  begin
    expect true do
      parser = Papyrus::Parser.new
      context = parser.send(:instance_variable_get, "@context")
      parser.equal?(context)
    end
    expect true do
      parser = Papyrus::Parser.new
      recent_parser = Papyrus::Parser.send(:class_variable_get, "@@recent_parser")
      parser.equal?(recent_parser)
    end
    expect(:foo => 'bar') do
      parser = Papyrus::Parser.new(:foo => 'bar')
      parser.send(:instance_variable_get, "@options")
    end
    begin
      expect nil do
        parser = Papyrus::Parser.new
        parser.send(:instance_variable_get, "@parent")
      end
      expect true do
        context = Papyrus::Context.new
        parser = Papyrus::Parser.new(:context => context)
        parser.send(:instance_variable_get, "@parent").equal?(context)
      end
      expect Papyrus::Context.to.receive(:construct_from).with(:context) do
        Papyrus::Parser.new(:context => :context)
      end
    end
    expect Papyrus::DefaultLexicon do
      parser = Papyrus::Parser.new
      parser.send(:instance_variable_get, "@lexicon")
    end
    expect Papyrus::DefaultPreprocessor do
      parser = Papyrus::Parser.new
      parser.send(:instance_variable_get, "@preprocessor")
    end
    expect :unescaped do
      parser = Papyrus::Parser.new
      parser.send(:instance_variable_get, "@default_processor")
    end
    expect %r|[./]| do
      parser = Papyrus::Parser.new
      parser.send(:instance_variable_get, "@method_separator_regexp")
    end
    begin
      expect Papyrus::FileSource do
        parser = Papyrus::Parser.new
        parser.send(:instance_variable_get, "@source")
      end
      expect Papyrus::StringSource do
        parser = Papyrus::Parser.new(:source => Papyrus::StringSource)
        parser.send(:instance_variable_get, "@source")
      end
    end
    expect nil do
      parser = Papyrus::Parser.new
      parser.send(:instance_variable_get, "@commands")
    end
  end
  
  # Parser#load
  begin
    expect Papyrus::Parser.new.to.receive(:compile).with("foo") do |parser|
      parser.load("foo")
    end
    expect Mocha::Mock do
      parser = Papyrus::Parser.new
      parser.stubs(:compile).returns stub('template')
      parser.load("")
    end
    expect true do
      parser = Papyrus::Parser.new
      parser.stubs(:compile).returns stub('template')
      template = parser.load("")
      parser.commands.equal?(template)
    end
  end
  
  # Parser#compile
  begin
    locally do
      parser = Papyrus::Parser.new
      expect parser.source.to.receive(:get).with("foo") do
        parser.compile("foo")
      end
    end
    # when body is a instance of Command::Base
    expect Papyrus::Command::Base do
      parser = Papyrus::Parser.new
      parser.source.stubs(:get).returns(Papyrus::Command::Base.new)
      parser.compile("")
    end
    # when body is not an instance of Command::Base
    begin
      expect Papyrus::Parser.new.to.receive(:parse).with("some content") do |parser|
        parser.source.stubs(:get).returns("some content")
        parser.source.stubs(:cache)
        parser.compile("")
      end
      locally do
        parser = Papyrus::Parser.new
        command = stub('command')
        expect parser.source.to.receive(:cache).with("foo", command) do
          parser.source.stubs(:get).returns("")
          parser.stubs(:parse).returns(command)
          parser.compile("foo")
        end
      end
      expect Mocha::Mock do
        parser = Papyrus::Parser.new
        parser.stubs(:parse).returns stub('template')
        parser.compile("")
      end
    end
    # when body is nil
    begin
      expect Papyrus::Template do
        parser = Papyrus::Parser.new
        parser.source.stubs(:get).returns(nil)
        parser.compile("")
      end
      expect "[ Template 'foo' not found ]" do
        parser = Papyrus::Parser.new
        parser.source.stubs(:get).returns(nil)
        template = parser.compile("foo")
        template.send(:instance_variable_get, "@command_block").first.to_s
      end
    end
  end
  
  # Parser#parse
  begin
    expect Papyrus::Parser.new.to.receive(:tokenize).with("This is the body", instance_of(Array)) do |parser|
      parser.parse("This is the body")
    end
    expect Papyrus::Template do
      Papyrus::Parser.new.parse("")
    end
  end
  
  #----
  
  # Parser#tokenize
  begin
    expect Papyrus::Parser.new.to.receive(:handle_command).with("This is some text ", "foo bar", []) do |parser|
      parser.stubs(:add_text_as_command_to_active_cmd)
      parser.send(:tokenize, "This is some text [% foo bar %]", [])
    end
    expect Papyrus::Parser.new.to.receive(:handle_command).times(2) do |parser|
      parser.stubs(:add_text_as_command_to_active_cmd)
      parser.send(:tokenize, "Blah blah [% foo %]\nSome more text [% bar baz foo %]", [])
    end
    expect ArgumentError do
      parser = Papyrus::Parser.new
      parser.stubs(:add_text_as_command_to_active_cmd)
      parser.send(:tokenize, "", [ :one, :two, :three ])
    end
  end
  
  # Parser#handle_command
  begin
    # ordinarily all four methods have the possibility of being called...
    begin
      expect Papyrus::Parser.new.to.receive(:add_text_as_command_to_active_cmd).with("This is some text", []) do |parser|
        parser.stubs(:modify_active_cmd)
        parser.stubs(:close_active_cmd)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "This is some text", "", [])
      end
      expect Papyrus::Parser.new.to.receive(:modify_active_cmd).with("foo bar", []) do |parser|
        parser.stubs(:add_text_as_command_to_active_cmd)
        parser.stubs(:close_active_cmd)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "foo bar", [])
      end
      expect Papyrus::Parser.new.to.receive(:close_active_cmd).with("foo bar", []) do |parser|
        parser.stubs(:add_text_as_command_to_active_cmd)
        parser.stubs(:modify_active_cmd)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "foo bar", [])
      end
      expect Papyrus::Parser.new.to.receive(:add_command_to_stack).with("foo bar", []) do |parser|
        parser.stubs(:add_text_as_command_to_active_cmd)
        parser.stubs(:modify_active_cmd)
        parser.stubs(:close_active_cmd)
        parser.send(:handle_command, "", "foo bar", [])
      end
    end
    # ...but if modify_active_cmd returns true...
    begin
      # ...then close_active_cmd won't be called...
      expect Papyrus::Parser.new.to.receive(:close_active_cmd).never do |parser|
        parser.stubs(:add_text_as_command_to_active_cmd)
        parser.stubs(:modify_active_cmd).returns(true)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "", [])
      end
      # ...and neither will add_command_to_stack
      expect Papyrus::Parser.new.to.receive(:add_command_to_stack).never do |parser|
        parser.stubs(:add_text_as_command_to_active_cmd)
        parser.stubs(:modify_active_cmd).returns(true)
        parser.stubs(:close_active_cmd)
        parser.send(:handle_command, "", "", [])
      end
    end
    # ...and add_command_to_stack won't be called if close_active_cmd returns true as well
    expect Papyrus::Parser.new.to.receive(:add_command_to_stack).never do |parser|
      parser.stubs(:add_text_as_command_to_active_cmd)
      parser.stubs(:modify_active_cmd)
      parser.stubs(:close_active_cmd).returns(true)
      parser.send(:handle_command, "", "", [])
    end
  end
  
  # Parser#add_text_as_command_to_active_cmd
  begin
    # if text is blank, don't do anything
    expect true do
      parser = Papyrus::Parser.new
      stack = [ Papyrus::Command::Block.new ]
      parser.send(:add_text_as_command_to_active_cmd, "", stack)
      stack.last.empty?
    end
    # if text is not blank, add it to the @command_block of the block command on active_cmd of the stack
    expect "some text" do
      parser = Papyrus::Parser.new
      stack = [ Papyrus::Command::Block.new ]
      parser.send(:add_text_as_command_to_active_cmd, "some text", stack)
      stack.last.first.to_s
    end
  end

  # Parser#modify_active_cmd
  begin
    # when active command modified by given command
    expect true do
      parser = Papyrus::Parser.new
      stack = [ stub('cmd', :modified_by? => true) ]
      parser.send(:modify_active_cmd, "", stack)
    end
    # when active command not modified by given command
    expect false do
      parser = Papyrus::Parser.new
      stack = [ stub('cmd', :modified_by? => false) ]
      parser.send(:modify_active_cmd, "", stack)
    end
  end

  # Parser#close_active_cmd
  begin
    # when active command modified by given command
    begin
      # stack should be popped
      expect 1 do
        parser = Papyrus::Parser.new
        stack = [ [], stub('cmd', :closed_by? => true) ]
        parser.send(:close_active_cmd, "", stack)
        stack.size
      end
      # active command should be moved to the one before it
      expect true do
        parser = Papyrus::Parser.new
        cmd = stub('cmd', :closed_by? => true)
        stack = [ [], cmd ]
        parser.send(:close_active_cmd, "", stack)
        stack.first == [cmd]
      end
      # return value
      expect true do
        parser = Papyrus::Parser.new
        stack = [ [], stub('cmd', :closed_by? => true) ]
        parser.send(:close_active_cmd, "", stack)
      end
    end
    # when active command not modified by given command
    expect false do
      parser = Papyrus::Parser.new
      stack = [ stub('cmd', :closed_by? => false) ]
      parser.send(:close_active_cmd, "", stack)
    end
  end
  
  # Parser#add_command_to_stack
  begin
    # if the command is Stackable, command should be added to stack
    expect Papyrus::Command::Case do
      parser = Papyrus::Parser.new
      stack = [ :command1 ]
      parser.lexicon.stubs(:lookup).returns Papyrus::Command::Case.new(nil, "", "")
      parser.send(:add_command_to_stack, "", stack)
      stack.last
    end
    # otherwise, command should be added to active command
    expect [[:command]] do
      parser = Papyrus::Parser.new
      stack = [ [] ]
      parser.lexicon.stubs(:lookup).returns(:command)
      parser.send(:add_command_to_stack, "", stack)
      stack
    end
  end

end