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
    class Bar < Base
    end
    class Baz < Stackable
    end
  end
end

Expectations do
  
  # .bra
  begin
    # when string passed
    expect "[%" do 
      PageTemplate::Lexicon.bra("[%")
      PageTemplate::Lexicon.send(:instance_variable_get, "@bra")
    end
    # when not string passed
    expect "[%" do 
      PageTemplate::Lexicon.send(:instance_variable_set, "@bra", "[%")
      PageTemplate::Lexicon.bra
    end
  end
  
  # .ket
  begin
    # when string passed
    expect "[%" do 
      PageTemplate::Lexicon.ket("[%")
      PageTemplate::Lexicon.send(:instance_variable_get, "@ket")
    end
    # when not string passed
    expect "[%" do 
      PageTemplate::Lexicon.send(:instance_variable_set, "@ket", "[%")
      PageTemplate::Lexicon.ket
    end
  end
  
  # .command_regexp
  begin
    # when @bra not defined
    expect RuntimeError do
      PageTemplate::Lexicon.send(:instance_variable_set, "@bra", nil)
      PageTemplate::Lexicon.send(:instance_variable_set, "@ket", nil)
      PageTemplate::Lexicon.command_regexp
    end
    # when @ket not defined
    expect RuntimeError do
      PageTemplate::Lexicon.send(:instance_variable_set, "@bra", "[%")
      PageTemplate::Lexicon.send(:instance_variable_set, "@ket", nil)
      PageTemplate::Lexicon.command_regexp
    end
    # as usual
    expect %r/\[%(.*)%\]/ do
      PageTemplate::Lexicon.send(:instance_variable_set, "@bra", "[%")
      PageTemplate::Lexicon.send(:instance_variable_set, "@ket", "%]")
      PageTemplate::Lexicon.command_regexp
    end
  end
  
  # .default
  begin
    # when symbol given
    expect PageTemplate::Command::Bar do
      PageTemplate::Lexicon.default(:bar)
      PageTemplate::Lexicon.send :instance_variable_get, "@default"
    end
    # when symbol not given, but @default already defined
    expect PageTemplate::Command::Bar do
      PageTemplate::Lexicon.send :instance_variable_set, "@default", PageTemplate::Command::Bar
      PageTemplate::Lexicon.default
    end
    # when symbol not given and @default not defined
    expect PageTemplate::Command::Unknown do
      PageTemplate::Lexicon.send :instance_variable_set, "@default", nil
      PageTemplate::Lexicon.default
    end
  end
  
  # .lookup
  begin
    # when the given command is defined in the command lexicon
    expect PageTemplate::Command::If do
      PageTemplate::Lexicon.send :instance_variable_set, "@commands", {
        PageTemplate::Command::If => { :regexp => /^(if) (.*)$/, :block => Proc.new {|m| m.captures } }
      }
      PageTemplate::Lexicon.lookup('if blah')
    end
    # when the given command is not defined in the command lexicon
    expect PageTemplate::Command::Unknown do
      PageTemplate::Lexicon.send :instance_variable_set, "@commands", {}
      PageTemplate::Lexicon.lookup('foo')
    end
  end
  
  # .modifier_on
  begin
    # modifiee is not a Stackable
    expect nil do
      PageTemplate::Lexicon.modifier_on("", PageTemplate::Command::Base.new)
    end
    # modifiee is a Stackable but modifiee doesn't respond to modifier
    expect nil do
      lex = PageTemplate::Lexicon
      lex.modifier_on("", PageTemplate::Command::Bar.new)
    end
    # commands does not include modifiee.class
    expect nil do
      lex = PageTemplate::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      lex.stubs(:commands).returns(Hash.new)
      lex.modifier_on("", PageTemplate::Command::Bar.new)
    end
    # commands includes modifiee.class but none of the modifier regexps match
    expect nil do
      lex = PageTemplate::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      foo_klass = PageTemplate::Command::Baz
      lex.stubs(:commands).returns(foo_klass => { :modifiers => { :foo => /bar/ } })
      lex.modifier_on("end", foo_klass.new)
    end
    # commands includes modifiee.class and one of the modifier regexps matches
    expect true do
      lex = PageTemplate::Lexicon
      lex.stubs(:modifiers).returns(Hash.new)
      foo_klass = PageTemplate::Command::Baz
      lex.stubs(:commands).returns(foo_klass => { :modifiers => { :end => /^end$/ } })
      ret = lex.modifier_on("end", foo_klass.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
    end
    # none of the global modifier regexps matches
    expect nil do
      lex = PageTemplate::Lexicon
      lex.stubs(:commands).returns(Hash.new)
      foo_klass = PageTemplate::Command::Baz
      lex.stubs(:modifiers).returns(:foo => proc { /bar/ })
      lex.modifier_on("end", foo_klass.new)
    end
    # some global modifier regexp matches
    expect true do
      lex = PageTemplate::Lexicon
      lex.stubs(:commands).returns(Hash.new)
      foo_klass = PageTemplate::Command::Baz
      lex.stubs(:modifiers).returns(:end => proc { /^end$/ })
      ret = lex.modifier_on("end", foo_klass.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
    end
  end
  
  # closer_on
  begin
    # modifiee is not a Stackable
    expect nil do
      PageTemplate::Lexicon.closer_on("", PageTemplate::Command::Base.new)
    end
    # closer is nil
    expect nil do
      PageTemplate::Lexicon.closer_on("", PageTemplate::Command::Baz.new)
    end
    # regexp doesn't match
    expect nil do
      PageTemplate::Lexicon.stubs(:closer).returns(:name => :foo, :block => proc { /foo/ })
      PageTemplate::Lexicon.closer_on("end", PageTemplate::Command::Baz.new)
    end
    # regexp does match
    expect true do
      PageTemplate::Lexicon.stubs(:closer).returns(:name => :end, :block => proc { /^end$/ })
      ret = PageTemplate::Lexicon.closer_on("end", PageTemplate::Command::Baz.new)
      ret[0] == :end && ret[1].is_a?(MatchData)
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
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo_bar) fslkdfsdfd$/i, 'FooBar', {}) do
      PageTemplate::Lexicon.define(:foo_bar, /fslkdfsdfd/)
    end
    # aliases
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo_bar|baz) fslkdfsdfd$/i, 'FooBar', {}) do
      PageTemplate::Lexicon.define(:foo_bar, /fslkdfsdfd/, :also => :baz)
    end
    # class_name
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo) fslkdfsdfd$/i, 'Baz', {}) do
      PageTemplate::Lexicon.define(:foo, /fslkdfsdfd/, :class_name => "Baz")
    end
    # modifiers
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo) fslkdfsdfd$/i, 'Baz', :foo => /^blah$/) do
      PageTemplate::Lexicon.define(:foo, /fslkdfsdfd/, :class_name => "Baz", :modifiers => { :foo => /^blah$/ })
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
      PageTemplate::Command.stubs(:const_get).returns(PageTemplate::Command::Bar)
      PageTemplate::Lexicon.adv_define(//, "")
      PageTemplate::Lexicon.send(:commands)[PageTemplate::Command::Bar][:block]
    end
    # when block given
    expect true do
      PageTemplate::Command.stubs(:const_get).returns(PageTemplate::Command::Bar)
      block = proc {|match| }
      PageTemplate::Lexicon.adv_define(//, "", &block)
      PageTemplate::Lexicon.send(:commands)[PageTemplate::Command::Bar][:block].equal?(block)
    end
    # when class_name does not refer to an existent Command class
    expect NameError do
      PageTemplate::Lexicon.adv_define(//, "Nonexistent")
    end
    # a value in the modifiers hash that's nil should be converted to a regexp
    expect %r/^foo$/ do
      PageTemplate::Command.stubs(:const_get).returns(PageTemplate::Command::Bar)
      PageTemplate::Lexicon.adv_define(//, "", { :foo => nil })
      PageTemplate::Lexicon.commands[PageTemplate::Command::Bar][:modifiers][:foo]
    end
    # as usual
    expect true do
      PageTemplate::Lexicon.adv_define(/(.*)/, "Filter")
      cmd = PageTemplate::Lexicon.send(:commands)[PageTemplate::Command::Filter]
      cmd[:regexp] == /(.*)/ && cmd[:block].is_a?(Proc)
    end
  end
  
  # .global_var
  begin
    # when regexp is not a regexp
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/^(foo(?:\.\w+\??)*)(?:\s:(\w+))?$/, 'Value') do
      PageTemplate::Lexicon.global_var(:foo)
    end
    # when regexp is a regexp
    expect PageTemplate::Lexicon.to.receive(:adv_define).with(/foo/, 'Value') do
      PageTemplate::Lexicon.global_var(/foo/)
    end
  end
  
  # .global_modifier
  begin
    # when neither regexp nor block given
    expect ArgumentError do
      PageTemplate::Lexicon.global_modifier(:end)
    end
    # when both regexp and block given
    expect ArgumentError do
      PageTemplate::Lexicon.global_modifier(:end, /foo/) { "bar" }
    end
    # when just regexp is given
    expect Proc do
      PageTemplate::Lexicon.global_modifier(:end, /foo/)
      PageTemplate::Lexicon.send(:modifiers)[:end]
    end
    # when just block is given
    expect Proc do
      PageTemplate::Lexicon.global_modifier(:end) {|x| /foo#{x}/ }
      PageTemplate::Lexicon.send(:modifiers)[:end]
    end
  end
  
  # .closer
  begin
    # when no args are given
    expect(:foo => :bar) do
      PageTemplate::Lexicon.send(:instance_variable_set, "@closer", :foo => :bar)
      PageTemplate::Lexicon.closer
    end
    # when neither regexp nor block given
    expect ArgumentError do
      PageTemplate::Lexicon.closer(:end)
    end
    # when both regexp and block given
    expect ArgumentError do
      PageTemplate::Lexicon.closer(:end, /foo/) { "bar" }
    end
    # when just regexp is given
    expect Proc do
      PageTemplate::Lexicon.closer(:end, /foo/)
      PageTemplate::Lexicon.closer[:block]
    end
    # when just block is given
    expect Proc do
      PageTemplate::Lexicon.global_modifier(:end) {|x| /foo#{x}/ }
      PageTemplate::Lexicon.closer[:block]
    end
  end
  
  # .commands
  begin
    # when @commands not defined yet
    expect Hash.new do
      PageTemplate::Lexicon.send(:instance_variable_set, "@commands", nil)
      PageTemplate::Lexicon.send(:commands)
    end
    # when @commands already defined
    expect(:foo => 'bar') do
      PageTemplate::Lexicon.send(:instance_variable_set, "@commands", { :foo => 'bar' })
      PageTemplate::Lexicon.send(:commands)
    end
  end
  
  # .modifiers
  begin
    # when @modifiers not defined yet
    expect Hash.new do
      PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", nil)
      PageTemplate::Lexicon.send(:modifiers)
    end
    # when @modifiers already defined
    expect(:foo => /bar/) do
      PageTemplate::Lexicon.send(:instance_variable_set, "@modifiers", { :foo => /bar/ })
      PageTemplate::Lexicon.send(:modifiers)
    end
  end
  
end