#
# FIXME
#

require File.dirname(__FILE__)+'/test_helper'

require 'command/base'
require 'command/unknown'
require 'command/value'
require 'command/stackable'
require 'command/block'
require 'command/filter'
require 'command/if'
require 'lexicon'

module Papyrus
  module Command
    class Bar < Base
    end
    class Baz < BlockCommand
    end
  end
end

Expectations do
  
  # .bra
  begin
    # when string passed
    expect "[%" do 
      Papyrus::Lexicon.bra("[%")
      Papyrus::Lexicon.send(:instance_variable_get, "@bra")
    end
    # when not string passed
    expect "[%" do 
      Papyrus::Lexicon.send(:instance_variable_set, "@bra", "[%")
      Papyrus::Lexicon.bra
    end
  end
  
  # .ket
  begin
    # when string passed
    expect "[%" do 
      Papyrus::Lexicon.ket("[%")
      Papyrus::Lexicon.send(:instance_variable_get, "@ket")
    end
    # when not string passed
    expect "[%" do 
      Papyrus::Lexicon.send(:instance_variable_set, "@ket", "[%")
      Papyrus::Lexicon.ket
    end
  end
  
  # .command_regexp
  begin
    # when @bra not defined
    expect RuntimeError do
      Papyrus::Lexicon.send(:instance_variable_set, "@bra", nil)
      Papyrus::Lexicon.send(:instance_variable_set, "@ket", nil)
      Papyrus::Lexicon.command_regexp
    end
    # when @ket not defined
    expect RuntimeError do
      Papyrus::Lexicon.send(:instance_variable_set, "@bra", "[%")
      Papyrus::Lexicon.send(:instance_variable_set, "@ket", nil)
      Papyrus::Lexicon.command_regexp
    end
    # as usual
    expect %r/\[%(.*)%\]/ do
      Papyrus::Lexicon.send(:instance_variable_set, "@bra", "[%")
      Papyrus::Lexicon.send(:instance_variable_set, "@ket", "%]")
      Papyrus::Lexicon.command_regexp
    end
  end
  
  # .default
  begin
    # when symbol given
    expect Papyrus::Command::Bar do
      Papyrus::Lexicon.default(:bar)
      Papyrus::Lexicon.send :instance_variable_get, "@default"
    end
    # when symbol not given, but @default already defined
    expect Papyrus::Command::Bar do
      Papyrus::Lexicon.send :instance_variable_set, "@default", Papyrus::Command::Bar
      Papyrus::Lexicon.default
    end
    # when symbol not given and @default not defined
    expect Papyrus::Command::Unknown do
      Papyrus::Lexicon.send :instance_variable_set, "@default", nil
      Papyrus::Lexicon.default
    end
  end
  
  # .lookup
  begin
    # when the given command is defined in the command lexicon
    expect Papyrus::Command::If do
      Papyrus::Lexicon.send :instance_variable_set, "@commands", {
        Papyrus::Command::If => { :regexp => /^(if) (.*)$/, :block => Proc.new {|m| m.captures } }
      }
      Papyrus::Lexicon.lookup('if blah')
    end
    # when the given command is not defined in the command lexicon
    expect Papyrus::Command::Unknown do
      Papyrus::Lexicon.send :instance_variable_set, "@commands", {}
      Papyrus::Lexicon.lookup('foo')
    end
  end
  
  # .modifier_on
  begin
    # modifiee is not a BlockCommand
    expect nil do
      Papyrus::Lexicon.modifier_on("", Papyrus::Command.new)
    end
    # modifiee is a BlockCommand but modifiee doesn't respond to modifier
    expect nil do
      lex = Papyrus::Lexicon
      lex.modifier_on("", Papyrus::Command::Bar.new)
    end
    # commands does not include modifiee.class
    expect nil do
      lex = Papyrus::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      lex.stubs(:commands).returns(Hash.new)
      lex.modifier_on("", Papyrus::Command::Bar.new)
    end
    # commands includes modifiee.class but none of the modifier regexps match
    expect nil do
      lex = Papyrus::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      foo_klass = Papyrus::Command::Baz
      lex.stubs(:commands).returns(foo_klass => { :modifiers => { :foo => /bar/ } })
      lex.modifier_on("end", foo_klass.new)
    end
    # commands includes modifiee.class and one of the modifier regexps matches
    expect true do
      lex = Papyrus::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      foo_klass = Papyrus::Command::Baz
      lex.stubs(:commands).returns(foo_klass => { :modifiers => { :end => /^end$/ } })
      ret = lex.modifier_on("end", foo_klass.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
    end
    # none of the global modifier regexps matches
    expect nil do
      lex = Papyrus::Lexicon
      lex.stubs(:commands).returns(Hash.new)
      foo_klass = Papyrus::Command::Baz
      lex.stubs(:modifiers).returns(:foo => proc { /bar/ })
      lex.modifier_on("end", foo_klass.new)
    end
    # some global modifier regexp matches
    expect true do
      lex = Papyrus::Lexicon
      lex.stubs(:commands).returns(Hash.new)
      foo_klass = Papyrus::Command::Baz
      lex.stubs(:modifiers).returns(:end => proc { /^end$/ })
      ret = lex.modifier_on("end", foo_klass.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
    end
  end
  
  # closer_on
  begin
    # modifiee is not a BlockCommand
    expect nil do
      Papyrus::Lexicon.closer_on("", Papyrus::Command.new)
    end
    # closer is nil
    expect nil do
      Papyrus::Lexicon.closer_on("", Papyrus::Command::Baz.new)
    end
    # regexp doesn't match
    expect nil do
      Papyrus::Lexicon.stubs(:closer).returns(:name => :foo, :block => proc { /foo/ })
      Papyrus::Lexicon.closer_on("end", Papyrus::Command::Baz.new)
    end
    # regexp does match
    expect true do
      Papyrus::Lexicon.stubs(:closer).returns(:name => :end, :block => proc { /^end$/ })
      ret = Papyrus::Lexicon.closer_on("end", Papyrus::Command::Baz.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
    end
  end
  
  # .define
  begin
    # when first argument is not a Symbol or String
    expect ArgumentError do
      Papyrus::Lexicon.define(/slkfsf/)
    end
    # when second argument is not a regexp
    expect ArgumentError do
      Papyrus::Lexicon.define(nil, "obviously not a regexp")
    end
    # regexp gets converted
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/^(foo_bar) fslkdfsdfd$/i, 'FooBar', {}) do
      Papyrus::Lexicon.define(:foo_bar, /fslkdfsdfd/)
    end
    # aliases
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/^(foo_bar|baz) fslkdfsdfd$/i, 'FooBar', {}) do
      Papyrus::Lexicon.define(:foo_bar, /fslkdfsdfd/, :also => :baz)
    end
    # class_name
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/^(foo) fslkdfsdfd$/i, 'Baz', {}) do
      Papyrus::Lexicon.define(:foo, /fslkdfsdfd/, :class_name => "Baz")
    end
    # modifiers
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/^(foo) fslkdfsdfd$/i, 'Baz', :foo => /^blah$/) do
      Papyrus::Lexicon.define(:foo, /fslkdfsdfd/, :class_name => "Baz", :modifiers => { :foo => /^blah$/ })
    end
  end
  
  # .adv_define
  begin
    # when first argument is not a Regexp
    expect ArgumentError do
      Papyrus::Lexicon.adv_define("obviously not a regexp", "")
    end
    # when block not given
    expect Proc do
      Papyrus::Command.stubs(:const_get).returns(Papyrus::Command::Bar)
      Papyrus::Lexicon.adv_define(//, "")
      Papyrus::Lexicon.send(:commands)[Papyrus::Command::Bar][:block]
    end
    # when block given
    expect true do
      Papyrus::Command.stubs(:const_get).returns(Papyrus::Command::Bar)
      block = proc {|match| }
      Papyrus::Lexicon.adv_define(//, "", &block)
      Papyrus::Lexicon.send(:commands)[Papyrus::Command::Bar][:block].equal?(block)
    end
    # when class_name does not refer to an existent Command class
    expect NameError do
      Papyrus::Lexicon.adv_define(//, "Nonexistent")
    end
    # a value in the modifiers hash that's nil should be converted to a regexp
    expect %r/^foo$/ do
      Papyrus::Command.stubs(:const_get).returns(Papyrus::Command::Bar)
      Papyrus::Lexicon.adv_define(//, "", { :foo => nil })
      Papyrus::Lexicon.commands[Papyrus::Command::Bar][:modifiers][:foo]
    end
    # as usual
    expect true do
      Papyrus::Lexicon.adv_define(/(.*)/, "Filter")
      cmd = Papyrus::Lexicon.send(:commands)[Papyrus::Command::Filter]
      cmd[:regexp] == /(.*)/ && cmd[:block].is_a?(Proc)
    end
  end
  
  # .global_var
  begin
    # when regexp is not a regexp
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/^(foo(?:\.\w+\??)*)(?:\s:(\w+))?$/, 'Value') do
      Papyrus::Lexicon.global_var(:foo)
    end
    # when regexp is a regexp
    expect Papyrus::Lexicon.to.receive(:adv_define).with(/foo/, 'Value') do
      Papyrus::Lexicon.global_var(/foo/)
    end
  end
  
  # .global_modifier
  begin
    # when neither regexp nor block given
    expect ArgumentError do
      Papyrus::Lexicon.global_modifier(:end)
    end
    # when both regexp and block given
    expect ArgumentError do
      Papyrus::Lexicon.global_modifier(:end, /foo/) { "bar" }
    end
    # when just regexp is given
    expect Proc do
      Papyrus::Lexicon.global_modifier(:end, /foo/)
      Papyrus::Lexicon.send(:modifiers)[:end]
    end
    # when just block is given
    expect Proc do
      Papyrus::Lexicon.global_modifier(:end) {|x| /foo#{x}/ }
      Papyrus::Lexicon.send(:modifiers)[:end]
    end
  end
  
  # .closer
  begin
    # when no args are given
    expect(:foo => :bar) do
      Papyrus::Lexicon.send(:instance_variable_set, "@closer", :foo => :bar)
      Papyrus::Lexicon.closer
    end
    # when neither regexp nor block given
    expect ArgumentError do
      Papyrus::Lexicon.closer(:end)
    end
    # when both regexp and block given
    expect ArgumentError do
      Papyrus::Lexicon.closer(:end, /foo/) { "bar" }
    end
    # when just regexp is given
    expect Proc do
      Papyrus::Lexicon.closer(:end, /foo/)
      Papyrus::Lexicon.closer[:block]
    end
    # when just block is given
    expect Proc do
      Papyrus::Lexicon.global_modifier(:end) {|x| /foo#{x}/ }
      Papyrus::Lexicon.closer[:block]
    end
  end
  
  # .commands
  begin
    # when @commands not defined yet
    expect Hash.new do
      Papyrus::Lexicon.send(:instance_variable_set, "@commands", nil)
      Papyrus::Lexicon.send(:commands)
    end
    # when @commands already defined
    expect(:foo => 'bar') do
      Papyrus::Lexicon.send(:instance_variable_set, "@commands", { :foo => 'bar' })
      Papyrus::Lexicon.send(:commands)
    end
  end
  
  # .modifiers
  begin
    # when @modifiers not defined yet
    expect Hash.new do
      Papyrus::Lexicon.send(:instance_variable_set, "@modifiers", nil)
      Papyrus::Lexicon.send(:modifiers)
    end
    # when @modifiers already defined
    expect(:foo => /bar/) do
      Papyrus::Lexicon.send(:instance_variable_set, "@modifiers", { :foo => /bar/ })
      Papyrus::Lexicon.send(:modifiers)
    end
  end
  
end