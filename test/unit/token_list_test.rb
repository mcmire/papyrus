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
    expect(:raw => "", :full => "") do
      TokenList.new.send(:instance_variable_get, "@cmd_info")
    end
    expect false do
      TokenList.new.send(:instance_variable_get, "@stash_curr_on_advance")
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
    # #stash_curr should be called on advance when @stash_curr_on_advance
    expect TokenList.new([]).to.receive(:stash_curr) do |tokens|
      tokens.send(:instance_variable_set, "@stash_curr_on_advance", true)
      tokens.advance
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
  
  # TokenList#start_stashing!
  begin
    expect true do
      tokens = TokenList.new
      tokens.start_stashing!
      tokens.send(:instance_variable_get, "@stash_curr_on_advance")
    end
    expect ["", ""] do
      tokens = TokenList.new
      tokens.start_stashing!
      cmd_info = tokens.send(:instance_variable_get, "@cmd_info")
      [ cmd_info[:raw], cmd_info[:full] ]
    end
  end
  
  # TokenList#stop_stashing!
  begin
    expect false do
      tokens = TokenList.new
      tokens.stop_stashing!
      tokens.send(:instance_variable_get, "@stash_curr_on_advance")
    end
  end
  
  # TokenList#stash_curr
  begin
    # raw should be added to, always
    expect "foo/bar" do
      tokens = TokenList.new
      cmd_info = { :raw => "foo/", :full => "foo/" }
      tokens.stubs(:cmd_info).returns(cmd_info)
      tokens.stubs(:curr).returns(Token::Text.new("bar"))
      tokens.stash_curr
      cmd_info[:raw]
    end
    # full should be added to when token is not a left or right bracket
    expect "foo/bar" do
      tokens = TokenList.new
      cmd_info = { :raw => "foo/", :full => "foo/" }
      tokens.stubs(:cmd_info).returns(cmd_info)
      tokens.stubs(:curr).returns(Token::Text.new("bar"))
      tokens.stash_curr
      cmd_info[:full]
    end
    # full should NOT be added to when token IS a left bracket
    expect "" do
      tokens = TokenList.new
      cmd_info = { :raw => "", :full => "" }
      tokens.stubs(:cmd_info).returns(cmd_info)
      tokens.stubs(:curr).returns(Token::LeftBracket.new)
      tokens.stash_curr
      cmd_info[:full]
    end
    # full should NOT be added to when token IS a right bracket
    expect "foo" do
      tokens = TokenList.new
      cmd_info = { :raw => "foo", :full => "foo" }
      tokens.stubs(:cmd_info).returns(cmd_info)
      tokens.stubs(:curr).returns(Token::RightBracket.new)
      tokens.stash_curr
      cmd_info[:full]
    end
  end
  
end