require File.dirname(__FILE__)+'/test_helper'

require 'lexicon'

Expectations do
  
  # .default when block given sets .@default
  expect Proc do
    PageTemplate::Lexicon.default { }
    PageTemplate::Lexicon.send :instance_variable_get, "@default"
  end
  # .default when block not given merely returns @default
  expect Proc do
    PageTemplate::Lexicon.send :instance_variable_set, "@default", Proc.new {}
    PageTemplate::Lexicon.default
  end
  
  # .lookup when the given command is defined in the command lexicon
  expect "a command" do
    PageTemplate::Lexicon.send :instance_variable_set, "@lexicon", { /foo/ => Proc.new { "a command" } }
    PageTemplate::Lexicon.lookup('foo')
  end
  # .lookup when the given command is not defined in the command lexicon should call default command
  expect "a command" do
    PageTemplate::Lexicon.send :instance_variable_set, "@lexicon", {}
    PageTemplate::Lexicon.default { "a command" }
    PageTemplate::Lexicon.lookup('foo')
  end
  
  # .modifies?
  expect true do
    PageTemplate::Lexicon.send :instance_variable_set, "@modifiers", { :foo => Proc.new { true } }
    PageTemplate::Lexicon.modifies?(:foo, "a command", "foo")
  end
  
  # .define when first argument is not a regexp
  expect ArgumentError do
    PageTemplate::Lexicon.define("obviously not a regexp") { }
  end
  # .define when block not given
  expect ArgumentError do
    PageTemplate::Lexicon.define(/foo/)
  end
  # .define as usual
  expect Proc do
    PageTemplate::Lexicon.define(/foo/) { }
    lexicon = PageTemplate::Lexicon.send :instance_variable_get, "@lexicon"
    lexicon[/foo/]
  end
  
  # .modifier when first argument is not a string or symbol
  expect ArgumentError do
    PageTemplate::Lexicon.modifier(/slfkdsf/)
  end
  # .modifier when block not given
  expect ArgumentError do
    PageTemplate::Lexicon.modifier(:foo)
  end
  # .modifier as usual
  expect Proc do
    PageTemplate::Lexicon.modifier(:foo) { true }
    PageTemplate::Lexicon.send(:modifiers)[:foo]
  end
  
  # .define_global_var converts argument to a regexp if it's not one already
  expect Proc do
    PageTemplate::Lexicon.define_global_var("foo")
    PageTemplate::Lexicon.send(:lexicon)[%r/^(foo(?:\.\w+\??)*)(?:\s:(\w+))?$/]
  end
  
  # .lexicon when @lexicon not defined yet
  expect Hash.new do
    PageTemplate::Lexicon.send(:instance_variable_set, "@lexicon", nil)
    PageTemplate::Lexicon.send(:lexicon)
  end
  # .lexicon when @lexicon already defined
  expect(:foo => 'bar') do
    PageTemplate::Lexicon.send(:instance_variable_set, "@lexicon", { :foo => 'bar' })
    PageTemplate::Lexicon.send(:lexicon)
  end
  
  # .modifiers when @modifiers not defined yet
  expect Hash.new(lambda { false }) do
    PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", nil)
    PageTemplate::Lexicon.send(:modifiers)
  end
  # .lexicon when @modifiers already defined
  expect(:foo => 'bar') do
    PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", { :foo => 'bar' })
    PageTemplate::Lexicon.send(:modifiers)
  end
  
end