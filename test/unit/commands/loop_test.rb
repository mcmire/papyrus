require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'command'
require 'block_command'
require 'commands/filter'
require 'commands/loop'
require 'text'
require 'context'

include Papyrus

class FakeContext < Hash
  attr_accessor :object
end

Expectations do
  
  # Loop#initialize
  begin
    expect 42 do
      loop_cmd = Commands::Loop.new(nil, "", [42, ""])
      loop_cmd.send(:instance_variable_get, "@value")
    end
    expect ['foo', 'bar', 'baz'] do
      loop_cmd = Commands::Loop.new(nil, "", ["", "foo bar baz"])
      loop_cmd.send(:instance_variable_get, "@block_params")
    end
    expect false do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_get, "@switched")
    end
    expect NodeList do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:commands)
    end
    expect NodeList do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:else_commands)
    end
    expect false do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_get, "@in_else")
    end
  end
  
  # Loop#else
  begin
    expect ArgumentError do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_set, "@switched", true)
      loop_cmd.else([])
    end
    expect false do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_set, "@in_else", true)
      loop_cmd.else([])
      loop_cmd.send(:instance_variable_get, "@in_else")
    end
    expect true do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.else([])
      loop_cmd.send(:instance_variable_get, "@switched")
    end
  end
  
  # Loop#add
  begin
    expect Command do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_set, "@in_else", true)
      loop_cmd << Command.new("", [])
      loop_cmd.send(:else_commands).last
    end
    expect Command do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:instance_variable_set, "@in_else", false)
      loop_cmd << Command.new("", [])
      loop_cmd.send(:commands).last
    end
  end
  
  # Loop#output
  begin
    # enum is nil
    expect stub('else_commands').to.receive(:output) do |else_commands|
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:parent).returns stub("parent", :get => nil)
      loop_cmd.stubs(:else_commands).returns(else_commands)
      loop_cmd.output
    end
    # enum is empty
    expect stub('else_commands').to.receive(:output) do |else_commands|
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:parent).returns stub("parent", :get => [])
      loop_cmd.stubs(:else_commands).returns(else_commands)
      loop_cmd.output
    end
    # enum is a String
    expect Array.any_instance.to.receive(:inject_with_index) do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:set_block_params)
      loop_cmd.stubs(:set_metavariables)
      loop_cmd.stubs(:parent).returns stub("parent", :get => "Not an enumerable")
      loop_cmd.stubs(:commands).stubs(:output).returns("")
      loop_cmd.output
    end
    # enum is not a String or Enumerable
    expect Array.any_instance.to.receive(:inject_with_index) do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:set_block_params)
      loop_cmd.stubs(:set_metavariables)
      loop_cmd.stubs(:parent).returns stub("parent", :get => Object.new)
      loop_cmd.stubs(:commands).stubs(:output).returns("")
      loop_cmd.output
    end
    # enum is an Enumerable
    expect "[@commands output][@commands output][@commands output]" do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:set_block_params)
      loop_cmd.stubs(:set_metavariables)
      loop_cmd.stubs(:parent).returns stub("parent", :get => [1, 2, 3])
      loop_cmd.send(:commands).stubs(:output).returns("[@commands output]")
      loop_cmd.output
    end
      
  end
  
  #---
  
  # Loop#set_block_params
  begin
    # @block_params nil
    expect :item do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:block_params).returns(nil)
      loop_cmd.send(:set_block_params, :item)
      loop_cmd.object
    end
    # @block_params empty
    expect :item do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:block_params).returns([])
      loop_cmd.send(:set_block_params, :item)
      loop_cmd.object
    end
    # item is an array and has more than one item
    begin
      # @block_params.size == item.size
      expect('foo' => 'one', 'bar' => 'two') do
        loop_cmd = Commands::Loop.new(nil, "", [])
        loop_cmd.stubs(:block_params).returns(['foo', 'bar'])
        loop_cmd.send(:set_block_params, ['one', 'two'])
        loop_cmd.vars
      end
      # @block_params.size > item.size
      expect('foo' => 'one', 'bar' => 'two', 'baz' => nil) do
        loop_cmd = Commands::Loop.new(nil, "", [])
        loop_cmd.stubs(:block_params).returns(['foo', 'bar', 'baz'])
        loop_cmd.send(:set_block_params, ['one', 'two'])
        loop_cmd.vars
      end
      # @block_params.size < item.size
      expect('foo' => 'one', 'bar' => 'two') do
        loop_cmd = Commands::Loop.new(nil, "", [])
        loop_cmd.stubs(:block_params).returns(['foo', 'bar'])
        loop_cmd.send(:set_block_params, ['one', 'two', 'three'])
        loop_cmd.vars
      end
    end
    # item is an array, but has only one item
    expect('foo' => ['one']) do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:block_params).returns(['foo'])
      loop_cmd.send(:set_block_params, ['one'])
      loop_cmd.vars
    end
    # item is not an array
    expect('foo' => {'key' => 'value'}) do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.stubs(:block_params).returns(['foo'])
      loop_cmd.send(:set_block_params, { 'key' => 'value' })
      loop_cmd.vars
    end
  end
  
  # Loop#set_metavariables
  begin
    # enum is not an array
    expect nil do
      loop_cmd = Commands::Loop.new(nil, "", [])
      loop_cmd.send(:set_metavariables, { 'key' => 'value'}, nil)
      loop_cmd['iter']
    end
    # enum is an array
    begin
      # is_first
      begin
        # true when 0
        expect true do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, [], 0)
          loop_cmd['iter']['is_first']
        end
        # false when not 0
        expect false do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, [], 3)
          loop_cmd['iter']['is_first']
        end
      end
      # is_last
      begin
        # true when -1
        expect true do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, ['one', 'two', 'three'], 2)
          loop_cmd['iter']['is_last']
        end
        # false when not -1
        expect false do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, ['one', 'two', 'three'], 0)
          loop_cmd['iter']['is_last']
        end
      end
      # is_odd
      begin
        # true when i % 2 != 0
        expect true do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, [], 1)
          loop_cmd['iter']['is_odd']
        end
        # false when i % 2 == 0
        expect false do
          loop_cmd = Commands::Loop.new(nil, "", [])
          loop_cmd.send(:set_metavariables, [], 0)
          loop_cmd['iter']['is_odd']
        end
      end
      # index, of course
      expect 2 do
        loop_cmd = Commands::Loop.new(nil, "", [])
        loop_cmd.send(:set_metavariables, [], 1)
        loop_cmd['iter']['index']
      end
    end
  end
  
  # Parser#to_s
  expect "[ Loop: foobarbazquux [ NodeList: [[ filter ]] [blah blah] ] Else: [ NodeList: [[ filter ]] [blah blah] ] ]" do
    loop_cmd = Commands::Loop.new(nil, "", [])
    loop_cmd.stubs(:value).returns(%w(foo bar baz quux))
    main_block = NodeList.new(nil, loop_cmd)
    main_block << Commands::Filter.new(nil, "filter", %w(unescaped))
    main_block << Text.new("blah blah")
    loop_cmd.stubs(:commands).returns(main_block)
    else_block = NodeList.new(nil, loop_cmd)
    else_block << Commands::Filter.new(nil, "filter", %w(unescaped))
    else_block << Text.new("blah blah")
    loop_cmd.stubs(:else_commands).returns(else_block)
    loop_cmd.to_s
  end

end