require File.dirname(__FILE__)+'/test_helper'

require 'token'
require 'token_list'

include Papyrus

Expectations do
  
  # TokenList#initialize
  begin
    expect ['foo', 'bar', 'baz'] do
      TokenList.new(['foo', 'bar', 'baz'])
    end
    expect -1 do
      TokenList.new.send(:instance_variable_get, "@pos")
    end
    expect Hash.new do
      TokenList.new.send(:instance_variable_get, "@cmd_info")
    end
    expect false do
      TokenList.new.send(:instance_variable_get, "@record")
    end
  end
  
  # TokenList#advance
  begin
    # no whitespace chars in token list
    expect Token::Text do
      list = [
        Token::LeftBracket.new,
        Token::Text.new,
        Token::Slash.new
      ]
      tokens = TokenList.new(list)
      tokens.pos = 0
      tokens.advance
    end
    # whitespace chars in token list should get skipped
    expect Token::Slash do
      list = [
        Token::LeftBracket.new,
        Token::Whitespace.new,
        Token::Slash.new
      ]
      tokens = TokenList.new(list)
      tokens.pos = 0
      tokens.advance
    end
    # raw and full should be stored when @record
    expect(:raw => "foo/bar", :full => "foo/bar") do
      list = [
        Token::Text.new("foo"),
        Token::Slash.new,
        Token::Text.new("bar")
      ]
      tokens = TokenList.new(list)
      tokens.start_recording!
      3.times { tokens.advance }
      tokens.cmd_info
    end
    # raw should include left and right brackets, but full should not
    expect(:raw => "[foo]", :full => "foo") do
      list = [
        Token::LeftBracket.new,
        Token::Text.new("foo"),
        Token::RightBracket.new
      ]
      tokens = TokenList.new(list)
      tokens.start_recording!
      3.times { tokens.advance }
      tokens.cmd_info
    end
  end
  
  # TokenList#curr
  expect Token::LeftBracket do
    list = [
      Token::Text.new,
      Token::LeftBracket.new,
      Token::Text.new
    ]
    tokens = TokenList.new(list)
    tokens.pos = 1
    tokens.curr
  end
  
  # TokenList#next
  expect Token::Text do
    list = [
      Token::Text.new,
      Token::LeftBracket.new,
      Token::Text.new
    ]
    tokens = TokenList.new(list)
    tokens.pos = 1
    tokens.next
  end
  
  # TokenList#prev
  expect Token::Text do
    list = [
      Token::Text.new,
      Token::LeftBracket.new,
      Token::Slash.new
    ]
    tokens = TokenList.new(list)
    tokens.pos = 1
    tokens.prev
  end
  
  # TokenList#start_recording!
  expect true do
    tokens = TokenList.new
    tokens.start_recording!
    tokens.send(:instance_variable_get, "@record")
  end
  
  # TokenList#stop_recording!
  begin
    expect false do
      tokens = TokenList.new
      tokens.stop_recording!
      tokens.send(:instance_variable_get, "@record")
    end
    expect ["", ""] do
      tokens = TokenList.new
      tokens.stop_recording!
      cmd_info = tokens.send(:instance_variable_get, "@cmd_info")
      [ cmd_info[:raw], cmd_info[:full] ]
    end
  end
  
end