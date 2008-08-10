require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/block'
require 'command/stackable'
require 'command/filter'
require 'command/if'
require 'command/text'

Expectations do
  
  # If#initialize
  begin
    expect 42 do
      if_cmd = Papyrus::Command::If.new(nil, "", 42)
      if_cmd.send(:instance_variable_get, "@value")
    end
    expect [ 42, Papyrus::Command::Block ] do
      if_cmd = Papyrus::Command::If.new(nil, "", 42)
      true_cmds = if_cmd.send(:instance_variable_get, "@true_commands")
      [ true_cmds.first[0], true_cmds.first[1].class ]
    end
    expect Papyrus::Command::Block do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_get, "@false_commands")
    end
    # @in_else
    begin
      expect false do
        if_cmd = Papyrus::Command::If.new(nil, "if", "")
        if_cmd.send(:instance_variable_get, "@in_else")
      end
      expect true do
        if_cmd = Papyrus::Command::If.new(nil, "unless", "")
        if_cmd.send(:instance_variable_get, "@in_else")
      end
    end
    expect false do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_get, "@switched")
    end
  end
  
  # If#add
  begin
    # when @in_else
    expect Papyrus::Command::Base do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_set, "@in_else", true)
      if_cmd << Papyrus::Command::Base.new
      if_cmd.send(:instance_variable_get, "@false_commands").last
    end
    # when not in @in_else
    expect Papyrus::Command::Base do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_set, "@in_else", false)
      if_cmd << Papyrus::Command::Base.new
      if_cmd.send(:instance_variable_get, "@true_commands").last.last
    end
  end
  
  # If#elsif
  begin
    # when @switched
    expect ArgumentError do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_get, "@switched", true)
      if_cmd.elsif(nil)
    end
    # when @in_else
    expect ArgumentError do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_get, "@in_else", true)
      if_cmd.elsif(nil)
    end
    # when not @switched or @in_else
    expect [ 42, Papyrus::Command::Block ] do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.elsif(42)
      last = if_cmd.send(:instance_variable_get, "@true_commands").last
      [ last[0], last[1].class ]
    end
  end
  
  # If#else
  begin
    # when @switched
    expect ArgumentError do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_set, "@switched", true)
      if_cmd.else
    end
    # when not @switched
    begin
      # @in_else should be reversed
      expect true do
        if_cmd = Papyrus::Command::If.new(nil, "", "")
        if_cmd.send(:instance_variable_set, "@in_else", false)
        if_cmd.else
        if_cmd.send(:instance_variable_get, "@in_else")
      end
      # @switched should be true
      expect true do
        if_cmd = Papyrus::Command::If.new(nil, "", "")
        if_cmd.else
        if_cmd.send(:instance_variable_get, "@switched")
      end
    end
  end

  # If#output
  begin
    # when one of the values in @true_commands is true
    expect "Output of true command" do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_set, "@true_commands", [ [ true, stub('block', :output => "Output of true command") ] ])
      if_cmd.output stub('context', :true? => true)
    end
    # when no values in @true_commands are true
    expect "Output of @false_commands" do
      if_cmd = Papyrus::Command::If.new(nil, "", "")
      if_cmd.send(:instance_variable_set, "@true_commands", [ [ false, nil ] ])
      if_cmd.send(:instance_variable_get, "@false_commands").stubs(:output).returns("Output of @false_commands")
      if_cmd.output stub('context', :true? => false)
    end
  end
  
  # If#to_s
  begin
    # when @called_as 'if'
    expect "[ If (42) [ Blocks: [foo bar] ] Elsif (foo) [ filter ] Else: [ Blocks: [bar baz] ] ]" do
      if_cmd = Papyrus::Command::If.new(nil, "if", "")
      if_cmd.send(:instance_variable_set, "@true_commands", [
        [ 42,    (Papyrus::Command::Block.new << Papyrus::Command::Text.new("foo bar")) ],
        [ 'foo', Papyrus::Command::Filter.new(nil, "filter", :unescaped) ]
      ])
      if_cmd.send(:instance_variable_set, "@false_commands",
        (Papyrus::Command::Block.new << Papyrus::Command::Text.new("bar baz")) )
      if_cmd.to_s
    end
    # when @called_as 'unless'
    expect "[ Unless (42): [ Blocks: [bar baz] ] Else: [ Blocks: [foo bar] ] ]" do
      if_cmd = Papyrus::Command::If.new(nil, "unless", 42)
      if_cmd.send(:instance_variable_set, "@false_commands",
        (Papyrus::Command::Block.new << Papyrus::Command::Text.new("bar baz")) )
      if_cmd.send(:instance_variable_set, "@true_commands", [
        [ nil, (Papyrus::Command::Block.new << Papyrus::Command::Text.new("foo bar")) ]
      ])
      if_cmd.to_s
    end
  end
  
end