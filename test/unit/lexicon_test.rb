require File.dirname(__FILE__)+'/test_helper'

require 'command/base'
require 'command/unknown'
require 'command/value'
require 'command/stackable'
require 'command/block'
require 'command/filter'
require 'command/if'
require 'lexicon'

module PageTemplate
  module Command
    class Foo < Base
    end
  end
end

Expectations do
  
  # .command_open
  begin
    # when string passed
    expect "[%" do 
      PageTemplate::Lexicon.command_open("[%")
      PageTemplate::Lexicon.send(:instance_variable_get, "@command_open")
    end
    # when not string passed
    expect "[%" do 
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_open", "[%")
      PageTemplate::Lexicon.command_open
    end
  end
  
  # .command_close
  begin
    # when string passed
    expect "[%" do 
      PageTemplate::Lexicon.command_close("[%")
      PageTemplate::Lexicon.send(:instance_variable_get, "@command_close")
    end
    # when not string passed
    expect "[%" do 
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_close", "[%")
      PageTemplate::Lexicon.command_close
    end
  end
  
  # .command_regexp
  begin
    # when @command_open not defined
    expect RuntimeError do
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_open", nil)
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_close", nil)
      PageTemplate::Lexicon.command_regexp
    end
    # when @command_close not defined
    expect RuntimeError do
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_open", "[%")
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_close", nil)
      PageTemplate::Lexicon.command_regexp
    end
    # as usual
    expect %r/\[%(.*)%\]/ do
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_open", "[%")
      PageTemplate::Lexicon.send(:instance_variable_set, "@command_close", "%]")
      PageTemplate::Lexicon.command_regexp
    end
  end
  
  # .default
  begin
    # when symbol given
    expect :foo_bar do
      PageTemplate::Lexicon.default(:foo_bar)
      PageTemplate::Lexicon.send :instance_variable_get, "@default"
    end
    # when symbol not given, but @default already defined
    expect :baz do
      PageTemplate::Lexicon.send :instance_variable_set, "@default", :baz
      PageTemplate::Lexicon.default
    end
    # when symbol not given and @default not defined
    expect :unknown do
      PageTemplate::Lexicon.send :instance_variable_set, "@default", nil
      PageTemplate::Lexicon.default
    end
  end
  
  # .lookup
  begin
    # when the given command is defined in the command lexicon
    expect PageTemplate::Command::If do
      PageTemplate::Lexicon.send :instance_variable_set, "@lexicon", {
        /^(if) (.*)$/ => { :klass => PageTemplate::Command::If, :block => Proc.new {|m| m.captures } }
      }
      PageTemplate::Lexicon.lookup('if blah')
    end
    # when the given command is not defined in the command lexicon
    expect PageTemplate::Command::Unknown do
      PageTemplate::Lexicon.send :instance_variable_set, "@lexicon", {}
      PageTemplate::Lexicon.lookup('foo')
    end
  end
  
  # .modifies?
  begin
    # when +modifier+ is a symbol
    expect true do
      PageTemplate::Lexicon.send :instance_variable_set, "@modifiers", { :foo => Proc.new { true } }
      PageTemplate::Lexicon.modifies?(:foo, "a command", "foo")
    end
    # when +modifier+ is a string
    expect true do
      PageTemplate::Lexicon.send :instance_variable_set, "@modifiers", { :foo => Proc.new { true } }
      PageTemplate::Lexicon.modifies?('foo', "a command", "foo")
    end
  end
  
  # .define
  begin
    # when first argument is not a Symbol or String
    expect ArgumentError do
      PageTemplate::Lexicon.define(/slkfsf/)
    end
    # when second argument is not a regexp
    expect ArgumentError do
      PageTemplate::Lexicon.define(nil, "obviously not a regexp")
    end
    # regexp gets converted
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo_bar) fslkdfsdfd$/i, 'FooBar') do
      PageTemplate::Lexicon.define(:foo_bar, /fslkdfsdfd/)
    end
    # aliases
    #expect PageTemplate::Lexicon.to.receive(:adv_define).with(any_of(/^(foo_bar) fslkdfsdfd$/i, /^(baz) fslkdfsdfd$/i), 'FooBar') do
    expect PageTemplate::Lexicon.to.receive(:adv_define).times(2) do
      PageTemplate::Lexicon.define(:foo_bar, /fslkdfsdfd/, :also => :baz)
    end
    # class_name
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo) fslkdfsdfd$/i, 'Baz') do
      PageTemplate::Lexicon.define(:foo, /fslkdfsdfd/, :class_name => "Baz")
    end
  end
  
  # .adv_define
  begin
    # when first argument is not a Regexp
    expect ArgumentError do
      PageTemplate::Lexicon.adv_define("obviously not a regexp", "")
    end
    # when block not given
    expect Proc do
      PageTemplate::Command.stubs(:const_get)
      PageTemplate::Lexicon.adv_define(/^(.*)$/, "")
      PageTemplate::Lexicon.send(:lexicon)[/^(.*)$/][:block]
    end
    # when block given
    expect true do
      PageTemplate::Command.stubs(:const_get)
      block = proc {|match| }
      PageTemplate::Lexicon.adv_define(/^(.*)$/, "", &block)
      PageTemplate::Lexicon.send(:lexicon)[/^(.*)$/][:block].equal?(block)
    end
    # when class_name does not refer to an existent Command class
    expect NameError do
      PageTemplate::Lexicon.adv_define(/^(.*)$/, "Nonexistent")
    end
    # as usual
    expect true do
      PageTemplate::Lexicon.adv_define(/^(.*)$/, "Filter")
      cmd = PageTemplate::Lexicon.send(:lexicon)[/^(.*)$/]
      cmd[:klass] == PageTemplate::Command::Filter && cmd[:block].is_a?(Proc)
    end
  end
  
  # .modifier
  begin
    # when first argument is not a string or symbol
    expect ArgumentError do
      PageTemplate::Lexicon.modifier(/slfkdsf/)
    end
    # when block not given
    expect ArgumentError do
      PageTemplate::Lexicon.modifier(:foo)
    end
    # when first argument is a symbol
    expect Proc do
      PageTemplate::Lexicon.modifier(:foo) { true }
      PageTemplate::Lexicon.send(:modifiers)[:foo]
    end
    # when first argument is a string
    expect Proc do
      PageTemplate::Lexicon.modifier('foo') { true }
      PageTemplate::Lexicon.send(:modifiers)[:foo]
    end
  end
  
  # .define_global_var
  begin
    # when regexp is not a regexp
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo(?:\.\w+\??)*)(?:\s:(\w+))?$/, 'Value') do
      PageTemplate::Lexicon.define_global_var(:foo)
    end
    # when regexp is a regexp
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/foo/, 'Value') do
      PageTemplate::Lexicon.define_global_var(/foo/)
    end
  end
  
  # .lexicon
  begin
    # when @lexicon not defined yet
    expect Hash.new do
      PageTemplate::Lexicon.send(:instance_variable_set, "@lexicon", nil)
      PageTemplate::Lexicon.send(:lexicon)
    end
    # when @lexicon already defined
    expect(:foo => 'bar') do
      PageTemplate::Lexicon.send(:instance_variable_set, "@lexicon", { :foo => 'bar' })
      PageTemplate::Lexicon.send(:lexicon)
    end
  end
  
  # .modifiers
  begin
    # when @modifiers not defined yet
    expect Hash.new(lambda { false }) do
      PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", nil)
      PageTemplate::Lexicon.send(:modifiers)
    end
    # when @modifiers already defined
    expect(:foo => 'bar') do
      PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", { :foo => 'bar' })
      PageTemplate::Lexicon.send(:modifiers)
    end
  end
  
end