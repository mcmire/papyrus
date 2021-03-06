require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'command'
require 'block_command'
require 'commands/filter'
require 'commands/if'
require 'text'

include Papyrus

Expectations do
  
  # If#initialize
  begin
    expect 42 do
      if_cmd = Commands::If.new(nil, "", [42])
      if_cmd.send(:instance_variable_get, "@value")
    end
    expect [ 42, NodeList ] do
      if_cmd = Commands::If.new(nil, "", [42])
      true_cmds = if_cmd.send(:instance_variable_get, "@true_commands")
      [ true_cmds.first[0], true_cmds.first[1].class ]
    end
    expect NodeList do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.send(:instance_variable_get, "@false_commands")
    end
    # @in_else
    begin
      expect false do
        if_cmd = Commands::If.new(nil, "if", [])
        if_cmd.send(:instance_variable_get, "@in_else")
      end
      expect true do
        if_cmd = Commands::If.new(nil, "unless", [])
        if_cmd.send(:instance_variable_get, "@in_else")
      end
    end
    expect false do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.send(:instance_variable_get, "@switched")
    end
  end
  
  # If#active_block
  begin
    # when in_else
    expect :false_commands do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.stubs(:in_else).returns(true)
      if_cmd.stubs(:false_commands).returns(:false_commands)
      if_cmd.active_block
    end
    # when not in_else
    expect :true_command do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.stubs(:in_else).returns(false)
      if_cmd.stubs(:true_commands).returns([[ nil, :true_command ]])
      if_cmd.active_block
    end
  end
    
  # If#elsif
  begin
    # when @switched
    expect ArgumentError do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.send(:instance_variable_get, "@switched", true)
      if_cmd.elsif([])
    end
    # when @in_else
    expect ArgumentError do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.send(:instance_variable_get, "@in_else", true)
      if_cmd.elsif([])
    end
    # when not @switched or @in_else
    expect [ 42, NodeList ] do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.elsif([42])
      last = if_cmd.send(:instance_variable_get, "@true_commands").last
      [ last[0], last[1].class ]
    end
  end
  
  # If#else
  begin
    # when @switched
    expect ArgumentError do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.send(:instance_variable_set, "@switched", true)
      if_cmd.else([])
    end
    # when not @switched
    begin
      # @in_else should be reversed
      expect true do
        if_cmd = Commands::If.new(nil, "", [])
        if_cmd.send(:instance_variable_set, "@in_else", false)
        if_cmd.else([])
        if_cmd.send(:instance_variable_get, "@in_else")
      end
      # @switched should be true
      expect true do
        if_cmd = Commands::If.new(nil, "", [])
        if_cmd.else([])
        if_cmd.send(:instance_variable_get, "@switched")
      end
    end
  end

  # If#output
  begin
    # when one of the values in @true_commands is true
    expect "Output of true command" do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.stubs(:parent).returns stub('parent', :true? => true)
      if_cmd.send(:instance_variable_set, "@true_commands", [
        [ "", stub('block', :output => "Output of true command") ]
      ])
      if_cmd.output
    end
    # when no values in @true_commands are true
    expect "Output of @false_commands" do
      if_cmd = Commands::If.new(nil, "", [])
      if_cmd.stubs(:parent).returns stub('parent', :true? => false)
      if_cmd.send(:instance_variable_set, "@true_commands", [ [ "", nil ] ])
      if_cmd.send(:instance_variable_get, "@false_commands").stubs(:output).returns("Output of @false_commands")
      if_cmd.output
    end
  end
  
  # If#to_s
  begin
    # when @called_as 'if'
    expect "[ If (42) [ NodeList: [foo bar] ] Elsif (foo) [ filter ] Else: [ NodeList: [bar baz] ] ]" do
      if_cmd = Commands::If.new(nil, "if", [])
      if_cmd.send(:instance_variable_set, "@true_commands", [
        [ 42,    (NodeList.new(nil, if_cmd) << Text.new("foo bar")) ],
        [ 'foo', Commands::Filter.new(nil, "filter", ["unescaped"]) ]
      ])
      if_cmd.send(:instance_variable_set, "@false_commands",
        (NodeList.new(nil, if_cmd) << Text.new("bar baz")) )
      if_cmd.to_s
    end
    # when @called_as 'unless'
    expect "[ Unless (42): [ NodeList: [bar baz] ] Else: [ NodeList: [foo bar] ] ]" do
      if_cmd = Commands::If.new(nil, "unless", [42])
      if_cmd.send(:instance_variable_set, "@false_commands",
        (NodeList.new(nil, if_cmd) << Text.new("bar baz")) )
      if_cmd.send(:instance_variable_set, "@true_commands", [
        [ nil, (NodeList.new(nil, if_cmd) << Text.new("foo bar")) ]
      ])
      if_cmd.to_s
    end
  end
  
end