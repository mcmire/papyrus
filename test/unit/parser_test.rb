require File.dirname(__FILE__)+'/test_helper'

require 'PageTemplate'

Expectations do
  
  # Parser.recent_parser
  begin
    # when @@recent_parser defined
    expect Mocha::Mock do
      PageTemplate::Parser.send(:class_variable_set, "@@recent_parser", stub('parser'))
      PageTemplate::Parser.recent_parser
    end
    # when @@recent_parser not defined
    expect nil do
      PageTemplate::Parser.send(:class_variable_set, "@@recent_parser", nil)
      PageTemplate::Parser.recent_parser
    end
  end
  
  # Parser.new
  begin
    expect true do
      parser = PageTemplate::Parser.new
      context = parser.send(:instance_variable_get, "@context")
      parser.equal?(context)
    end
    expect true do
      parser = PageTemplate::Parser.new
      recent_parser = PageTemplate::Parser.send(:class_variable_get, "@@recent_parser")
      parser.equal?(recent_parser)
    end
    expect(:foo => 'bar') do
      parser = PageTemplate::Parser.new(:foo => 'bar')
      parser.send(:instance_variable_get, "@options")
    end
    begin
      expect nil do
        parser = PageTemplate::Parser.new
        parser.send(:instance_variable_get, "@parent")
      end
      expect true do
        context = PageTemplate::Context.new
        parser = PageTemplate::Parser.new(:context => context)
        parser.send(:instance_variable_get, "@parent").equal?(context)
      end
      expect PageTemplate::Context.to.receive(:construct_from).with(:context) do
        PageTemplate::Parser.new(:context => :context)
      end
    end
    expect PageTemplate::DefaultLexicon do
      parser = PageTemplate::Parser.new
      parser.send(:instance_variable_get, "@lexicon")
    end
    expect PageTemplate::DefaultPreprocessor do
      parser = PageTemplate::Parser.new
      parser.send(:instance_variable_get, "@preprocessor")
    end
    expect :unescaped do
      parser = PageTemplate::Parser.new
      parser.send(:instance_variable_get, "@default_processor")
    end
    expect %r|[./]| do
      parser = PageTemplate::Parser.new
      parser.send(:instance_variable_get, "@method_separator_regexp")
    end
    begin
      expect PageTemplate::FileSource do
        parser = PageTemplate::Parser.new
        parser.send(:instance_variable_get, "@source")
      end
      expect PageTemplate::StringSource do
        parser = PageTemplate::Parser.new(:source => PageTemplate::StringSource)
        parser.send(:instance_variable_get, "@source")
      end
    end
    expect nil do
      parser = PageTemplate::Parser.new
      parser.send(:instance_variable_get, "@commands")
    end
  end
  
  # Parser#load
  begin
    expect PageTemplate::Parser.new.to.receive(:compile).with("foo") do |parser|
      parser.load("foo")
    end
    expect Mocha::Mock do
      parser = PageTemplate::Parser.new
      parser.stubs(:compile).returns stub('template')
      parser.load("")
    end
    expect true do
      parser = PageTemplate::Parser.new
      parser.stubs(:compile).returns stub('template')
      template = parser.load("")
      parser.commands.equal?(template)
    end
  end
  
  # Parser#compile
  begin
    locally do
      parser = PageTemplate::Parser.new
      expect parser.source.to.receive(:get).with("foo") do
        parser.compile("foo")
      end
    end
    # when body is a instance of Command::Base
    expect PageTemplate::Command::Base do
      parser = PageTemplate::Parser.new
      parser.source.stubs(:get).returns(PageTemplate::Command::Base.new)
      parser.compile("")
    end
    # when body is not an instance of Command::Base
    begin
      expect PageTemplate::Parser.new.to.receive(:parse).with("some content") do |parser|
        parser.source.stubs(:get).returns("some content")
        parser.source.stubs(:cache)
        parser.compile("")
      end
      locally do
        parser = PageTemplate::Parser.new
        command = stub('command')
        expect parser.source.to.receive(:cache).with("foo", command) do
          parser.source.stubs(:get).returns("")
          parser.stubs(:parse).returns(command)
          parser.compile("foo")
        end
      end
      expect Mocha::Mock do
        parser = PageTemplate::Parser.new
        parser.stubs(:parse).returns stub('template')
        parser.compile("")
      end
    end
    # when body is nil
    begin
      expect PageTemplate::Template do
        parser = PageTemplate::Parser.new
        parser.source.stubs(:get).returns(nil)
        parser.compile("")
      end
      expect "[ Template 'foo' not found ]" do
        parser = PageTemplate::Parser.new
        parser.source.stubs(:get).returns(nil)
        template = parser.compile("foo")
        template.send(:instance_variable_get, "@command_block").first.to_s
      end
    end
  end
  
  # Parser#parse
  expect PageTemplate::Parser.new.to.receive(:tokenize).with("This is the body") do |parser|
    parser.parse("This is the body")
  end
  
  #----
  
  # Parser#tokenize
  begin
    expect PageTemplate::Parser.new.to.receive(:handle_command).with("This is some text ", "foo bar") do |parser|
      parser.stubs(:add_text_as_command_to_top)
      parser.send(:stack=, [])
      parser.send(:tokenize, "This is some text [% foo bar %]")
    end
    expect PageTemplate::Parser.new.to.receive(:handle_command).times(2) do |parser|
      parser.stubs(:add_text_as_command_to_top)
      parser.send(:stack=, [])
      parser.send(:tokenize, "Blah blah [% foo %]\nSome more text [% bar baz foo %]")
    end
    expect ArgumentError do
      parser = PageTemplate::Parser.new
      parser.stubs(:add_text_as_command_to_top)
      parser.send(:stack).stubs(:size).returns(2)
      parser.send(:tokenize, "")
    end
  end
  
  # Parser#handle_command
  begin
    # ordinarily all four methods will be called...
    begin
      expect PageTemplate::Parser.new.to.receive(:add_text_as_command_to_top).with("This is some text") do |parser|
        parser.stubs(:command_modifies_top_command?)
        parser.stubs(:command_closed_top_command?)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "This is some text", "")
      end
      expect PageTemplate::Parser.new.to.receive(:command_modifies_top_command?).with("foo bar") do |parser|
        parser.stubs(:add_text_as_command_to_top)
        parser.stubs(:command_closed_top_command?)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "foo bar")
      end
      expect PageTemplate::Parser.new.to.receive(:command_closed_top_command?).with("foo bar") do |parser|
        parser.stubs(:add_text_as_command_to_top)
        parser.stubs(:command_modifies_top_command?)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "foo bar")
      end
      expect PageTemplate::Parser.new.to.receive(:add_command_to_stack).with("foo bar") do |parser|
        parser.stubs(:add_text_as_command_to_top)
        parser.stubs(:command_modifies_top_command?)
        parser.stubs(:command_closed_top_command?)
        parser.send(:handle_command, "", "foo bar")
      end
    end
    # ...but if command_modifies_top_command? returns true...
    begin
      # ...then command_closed_top_command? won't be called...
      expect PageTemplate::Parser.new.to.receive(:command_closed_top_command?).never do |parser|
        parser.stubs(:add_text_as_command_to_top)
        parser.stubs(:command_modifies_top_command?).returns(true)
        parser.stubs(:add_command_to_stack)
        parser.send(:handle_command, "", "")
      end
      # ...and neither will add_command_to_stack
      expect PageTemplate::Parser.new.to.receive(:add_command_to_stack).never do |parser|
        parser.stubs(:add_text_as_command_to_top)
        parser.stubs(:command_modifies_top_command?).returns(true)
        parser.stubs(:command_closed_top_command?)
        parser.send(:handle_command, "", "")
      end
    end
    # ...and add_command_to_stack won't be called if command_closed_top_command? returns true as well
    expect PageTemplate::Parser.new.to.receive(:add_command_to_stack).never do |parser|
      parser.stubs(:add_text_as_command_to_top)
      parser.stubs(:command_modifies_top_command?)
      parser.stubs(:command_closed_top_command?).returns(true)
      parser.send(:handle_command, "", "")
    end
  end
  
  # Parser#add_text_as_command_to_top
  begin
    # if text is blank, don't do anything
    expect true do
      parser = PageTemplate::Parser.new
      parser.send(:stack=, [ PageTemplate::Command::Block.new ])
      parser.send(:add_text_as_command_to_top, "")
      parser.send(:stack).last.empty?
    end
    # if text is not blank, add it to the @command_block of the block command on top of the stack
    expect "some text" do
      parser = PageTemplate::Parser.new
      parser.send(:stack=, [ PageTemplate::Command::Block.new ])
      parser.send(:add_text_as_command_to_top, "some text")
      parser.send(:stack).last.first.to_s
    end
  end

  # Parser#command_modifies_top_command?
  begin
    # when @modifier not defined
    expect false do
      parser = PageTemplate::Parser.new
      parser.send(:modifier=, nil)
      parser.send(:command_modifies_top_command?, "")
    end
    # when @modifier defined but given command doesn't modify @top command
    expect false do
      parser = PageTemplate::Parser.new
      parser.send(:modifier=, :something)
      parser.lexicon.stubs(:modifies?).returns(false)
      parser.send(:command_modifies_top_command?, "")
    end
    # when @modifier defined and given command modifies @top command
    expect true do
      parser = PageTemplate::Parser.new
      parser.send(:modifier=, :something)
      parser.lexicon.stubs(:modifies?).returns(true)
      parser.send(:command_modifies_top_command?, "")
    end
  end

  # Parser#command_closed_top_command?
  begin
    # when @closer not defined
    expect false do
      parser = PageTemplate::Parser.new
      parser.send(:closer=, nil)
      parser.send(:command_closed_top_command?, "")
    end
    # when @closer defined, but given command doesn't close @top command
    expect false do
      parser = PageTemplate::Parser.new
      parser.send(:closer=, :something)
      parser.lexicon.stubs(:modifies?).returns(false)
      parser.send(:command_closed_top_command?, "")
    end
    # when @closer defined and given command closes @top command
    begin
      # @stack should be pop'ped
      expect 1 do
        parser = PageTemplate::Parser.new
        parser.send(:stack=, [ parser.new_template, PageTemplate::Command::Filter.new(:unescaped) ])
        parser.send(:closer=, :something)
        parser.lexicon.stubs(:modifies?).returns(true)
        parser.send(:command_closed_top_command?, "")
        parser.send(:stack).size
      end
      # @top command should be moved to one before it and @top updated accordingly
      expect [true, true] do
        parser = PageTemplate::Parser.new
        template = parser.new_template
        filter = PageTemplate::Command::Filter.new(:unescaped)
        stack = [ template, filter ]
        parser.send(:stack=, stack)
        parser.send(:top=, stack.last)
        parser.send(:closer=, :something)
        parser.lexicon.stubs(:modifies?).returns(true)
        parser.send(:command_closed_top_command?, "")
        [ parser.send(:top).equal?(template), template.last.equal?(filter) ]
      end
      # @modifier and @closer should be reset
      expect [:elsif, :end] do
        parser = PageTemplate::Parser.new
        parser.send(:stack=, [ parser.new_template, PageTemplate::Command::If.new('if', true), PageTemplate::Command::If.new('if', true) ])
        parser.send(:closer=, :something)
        parser.lexicon.stubs(:modifies?).returns(true)
        parser.send(:command_closed_top_command?, "")
        [ parser.send(:modifier), parser.send(:closer) ]
      end
    end
  end
  
  # Parser#add_command_to_stack
  begin
    locally do
      parser = PageTemplate::Parser.new
      expect parser.lexicon.to.receive(:lookup).with("foo bar") do
        parser.send(:top=, [])
        parser.send(:add_command_to_stack, "foo bar")
      end
    end
    # if the command is Stackable
    begin
      # modifier and closer should be reset
      expect [:elsif, :end] do
        parser = PageTemplate::Parser.new
        parser.send(:stack=, [ parser.new_template ])
        parser.lexicon.stubs(:lookup).returns PageTemplate::Command::If.new('if', true)
        parser.send(:add_command_to_stack, "")
        [ parser.send(:modifier), parser.send(:closer) ]
      end
      # command should be added to stack
      expect PageTemplate::Command::If do
        parser = PageTemplate::Parser.new
        parser.send(:stack=, [ parser.new_template ])
        parser.lexicon.stubs(:lookup).returns PageTemplate::Command::If.new('if', true)
        parser.send(:add_command_to_stack, "")
        parser.send(:stack).last
      end
      # @top should be reset
      expect PageTemplate::Command::If do
        parser = PageTemplate::Parser.new
        parser.send(:stack=, [ parser.new_template ])
        parser.lexicon.stubs(:lookup).returns PageTemplate::Command::If.new('if', true)
        parser.send(:add_command_to_stack, "")
        parser.send(:top)
      end
    end
  end

end