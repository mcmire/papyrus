require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/block'
require 'command/stackable'
require 'command/loop'
require 'command/filter'
require 'command/text'
require 'context_item'
require 'context'

#require 'Papyrus'

class FakeContext < Hash
  attr_accessor :object
end

Expectations do
  
  # Loop#initialize
  begin
    expect 42 do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", 42, "")
      loop_cmd.send(:instance_variable_get, "@value")
    end
    expect ['foo', 'bar', 'baz'] do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "foo bar baz")
      loop_cmd.send(:instance_variable_get, "@block_params")
    end
    expect false do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_get, "@switched")
    end
    expect Papyrus::Command::Block do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_get, "@commands")
    end
    expect Papyrus::Command::Block do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_get, "@else_commands")
    end
    expect false do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_get, "@in_else")
    end
  end
  
  # Loop#else
  begin
    expect ArgumentError do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@switched", true)
      loop_cmd.else
    end
    expect false do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@in_else", true)
      loop_cmd.else
      loop_cmd.send(:instance_variable_get, "@in_else")
    end
    expect true do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.else
      loop_cmd.send(:instance_variable_get, "@switched")
    end
  end
  
  # Loop#add
  begin
    expect Papyrus::Command::Block do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@in_else", true)
      loop_cmd << Papyrus::Command::Block.new
      loop_cmd.send(:instance_variable_get, "@else_commands").last
    end
    expect Papyrus::Command::Block do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@in_else", false)
      loop_cmd << Papyrus::Command::Block.new
      loop_cmd.send(:instance_variable_get, "@commands").last
    end
  end
  
  # Loop#output
  begin
    # enum is nil
    expect stub('else_commands').to.receive(:output) do |else_commands|
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@else_commands", else_commands)
      loop_cmd.output stub('context', :get => nil)
    end
    # enum is empty
    expect stub('else_commands').to.receive(:output) do |else_commands|
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@else_commands", else_commands)
      loop_cmd.output stub('context', :get => [])
    end
    # enum is not an Enumerable
    expect true do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.stubs(:create_subcontext)
      loop_cmd.send(:instance_variable_get, "@commands").stubs(:output).returns("")
      e = nil
      begin
        loop_cmd.output stub('context', :get => Class.new) # kind of weird, but anyway...
      rescue Exception => e; end
      !(e.is_a?(NoMethodError) && e.message =~ /undefined method `inject_with_index'/)
    end
  end
  
  #---
  
  # Loop#create_subcontext
  begin
    expect Papyrus::Command::Loop.new(nil, "", "", "").to.receive(:set_block_params) do |loop_cmd|
      loop_cmd.send(:create_subcontext, nil, nil, nil, nil)
    end
    expect Papyrus::Command::Loop.new(nil, "", "", "").to.receive(:set_metavariables) do |loop_cmd|
      loop_cmd.send(:create_subcontext, nil, nil, nil, nil)
    end
  end
  
  # Loop#set_block_params
  begin
    # @block_params nil
    expect :item do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@block_params", nil)
      context = FakeContext.new
      loop_cmd.send(:set_block_params, context, :item)
      context.object
    end
    # @block_params empty
    expect :item do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@block_params", [])
      context = FakeContext.new
      loop_cmd.send(:set_block_params, context, :item)
      context.object
    end
    # item is an array and has more than one item
    begin
      # @block_params.size == item.size
      expect('foo' => 'one', 'bar' => 'two') do
        loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
        loop_cmd.send(:instance_variable_set, "@block_params", ['foo', 'bar'])
        context = FakeContext.new
        loop_cmd.send(:set_block_params, context, ['one', 'two'])
        context
      end
      # @block_params.size > item.size
      expect('foo' => 'one', 'bar' => 'two', 'baz' => nil) do
        loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
        loop_cmd.send(:instance_variable_set, "@block_params", ['foo', 'bar', 'baz'])
        context = FakeContext.new
        loop_cmd.send(:set_block_params, context, ['one', 'two'])
        context
      end
      # @block_params.size < item.size
      expect('foo' => 'one', 'bar' => 'two') do
        loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
        loop_cmd.send(:instance_variable_set, "@block_params", ['foo', 'bar'])
        context = FakeContext.new
        loop_cmd.send(:set_block_params, context, ['one', 'two', 'three'])
        context
      end
    end
    # item is an array, but has only one item
    expect('foo' => ['one']) do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@block_params", ['foo'])
      context = FakeContext.new
      loop_cmd.send(:set_block_params, context, ['one'])
      context
    end
    # item is not an array
    expect('foo' => {'key' => 'value'}) do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      loop_cmd.send(:instance_variable_set, "@block_params", ['foo'])
      context = FakeContext.new
      loop_cmd.send(:set_block_params, context, { 'key' => 'value' })
      context
    end
  end
  
  # Loop#set_metavariables
  begin
    # enum is not an array
    expect nil do
      loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
      context = FakeContext.new
      loop_cmd.send(:set_metavariables, context, { 'key' => 'value'}, nil)
      context['iter']
    end
    # enum is an array
    begin
      # is_first
      begin
        # true when 0
        expect true do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, [], 0)
          context['iter']['is_first']
        end
        # false when not 0
        expect false do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, [], 3)
          context['iter']['is_first']
        end
      end
      # is_last
      begin
        # true when -1
        expect true do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, ['one', 'two', 'three'], 2)
          context['iter']['is_last']
        end
        # false when not -1
        expect false do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, ['one', 'two', 'three'], 0)
          context['iter']['is_last']
        end
      end
      # is_odd
      begin
        # true when i % 2 != 0
        expect true do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, [], 1)
          context['iter']['is_odd']
        end
        # false when i % 2 == 0
        expect false do
          loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
          context = FakeContext.new
          loop_cmd.send(:set_metavariables, context, [], 0)
          context['iter']['is_odd']
        end
      end
      # index, of course
      expect 2 do
        loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
        context = FakeContext.new
        loop_cmd.send(:set_metavariables, context, [], 1)
        context['iter']['index']
      end
    end
  end
  
  # Parser#to_s
  expect "[ Loop: foobarbazquux [ Blocks: [[ filter ]] [blah blah] ] Else: [ Blocks: [[ filter ]] [blah blah] ] ]" do
    loop_cmd = Papyrus::Command::Loop.new(nil, "", "", "")
    loop_cmd.send(:instance_variable_set, "@value", %w(foo bar baz quux))
    main_block = Papyrus::Command::Block.new
    main_block << Papyrus::Command::Filter.new(nil, "filter", :unescaped)
    main_block << Papyrus::Command::Text.new("blah blah")
    loop_cmd.send(:instance_variable_set, "@commands", main_block)
    else_block = Papyrus::Command::Block.new
    else_block << Papyrus::Command::Filter.new(nil, "filter", :unescaped)
    else_block << Papyrus::Command::Text.new("blah blah")
    loop_cmd.send(:instance_variable_set, "@else_commands", else_block)
    loop_cmd.to_s
  end

end