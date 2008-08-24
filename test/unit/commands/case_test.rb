require File.dirname(__FILE__)+'/../test_helper'

require 'node'
require 'context_item'
require 'node_list'
require 'command'
require 'block_command'
require 'commands/case'

Expectations do
  
  # Case#initialize
  begin
    # @value
    expect "foo" do
      Papyrus::Commands::Case.new(nil, "", ["foo"]).send(:instance_variable_get, "@value")
    end
    # @blocks
    expect({}) do
      Papyrus::Commands::Case.new(nil, "", []).send(:instance_variable_get, "@blocks")
    end
    # @current_case
    expect nil do
      Papyrus::Commands::Case.new(nil, "", []).send(:instance_variable_get, "@current_case")
    end
    # @default
    expect Papyrus::NodeList do
      Papyrus::Commands::Case.new(nil, "", []).send(:instance_variable_get, "@default")
    end
  end
   
  # Case#add
  begin
    # when @current_case defined
    expect true do
      cmd = Papyrus::Command.new("", [])
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.send(:instance_variable_set, "@current_case", "foo")
      blocks = case_cmd.send(:instance_variable_get, "@blocks")
      blocks["foo"] = Papyrus::NodeList.new(case_cmd)
      case_cmd.add(cmd)
      blocks["foo"].last.equal?(cmd)
    end
    # when @current_case not defined
    expect true do
      cmd = Papyrus::Command.new("", [])
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.add(cmd)
      case_cmd.send(:instance_variable_get, "@default").last.equal?(cmd)
    end
  end
   
  # Case#when
  begin
    expect "foo" do
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.when(["foo"])
      case_cmd.current_case
    end
    # @blocks[value] should be set when not @blocks.has_key?(value)
    expect Papyrus::NodeList do
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.when(["foo"])
      case_cmd.send(:instance_variable_get, "@blocks")["foo"]
    end
  end
 
  # Case#else
  begin
    expect true do
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.else([])
    end
    expect nil do
      case_cmd = Papyrus::Commands::Case.new(nil, "", [])
      case_cmd.else([])
      case_cmd.current_case
    end
  end
  
  # Case#output
  expect "Output of first block" do
    case_cmd = Papyrus::Commands::Case.new(nil, "", [])
    case_cmd.stubs(:parent).returns stub("parent", :get => "foo")
    case_cmd.send(:instance_variable_set, "@blocks", {
      'foo' => stub('block1', :output => "Output of first block"),
      'bar' => stub('block2', :output => "Output of second block")
    })
    case_cmd.output
  end
  
  # Case#to_s
  expect "[ Case:  foo: [Foo as string] bar: [Bar as string] else Default case ]" do
    case_cmd = Papyrus::Commands::Case.new(nil, "", [])
    case_cmd.send(:instance_variable_set, "@blocks", {
      'foo' => stub('block1', :to_s => "Foo as string"),
      'bar' => stub('block2', :to_s => "Bar as string")
    })
    case_cmd.send(:instance_variable_set, "@default", stub('default', :to_s => "Default case"))
    case_cmd.to_s
  end
   
end