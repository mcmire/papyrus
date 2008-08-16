#
# FIXME
#

require File.dirname(__FILE__)+'/test_helper'

require 'papyrus'

include Papyrus

Expectations do
  
  # Parser.new
  begin
    # set @@recent_parser
    expect true do
      parser = Parser.new(nil)
      recent_parser = Parser.send(:class_variable_get, "@@recent_parser")
      parser.equal?(recent_parser)
    end
    begin
      # @parent is not set
      expect nil do
        parser = Parser.new(nil)
        parser.send(:instance_variable_get, "@parent")
      end
      # @parent == given context
      expect true do
        context = Context.new
        parser = Parser.new(nil, context)
        parser.send(:instance_variable_get, "@parent").equal?(context)
      end
      expect Context.to.receive(:construct_from).with(:context) do
        Parser.new(nil, :context)
      end
    end
    # @parser
    expect true do
      parser = Parser.new(nil)
      parser.parser.equal?(parser)
    end
    # @stack
    expect true do
      parser = Parser.new(nil)
      parser.stack.is_a?(Array) && parser.stack.first.is_a?(Template)
    end
  end
  
  # Parser.recent_parser
  begin
    # when @@recent_parser defined
    expect :recent_parser do
      Parser.send(:class_variable_set, "@@recent_parser", :recent_parser)
      Parser.recent_parser
    end
    # when @@recent_parser not defined
    expect nil do
      Parser.send(:class_variable_set, "@@recent_parser", nil)
      Parser.recent_parser
    end
  end
  
  # Parser#tokenize
  begin
    expect [
      Token::Text, Token::LeftBracket, Token::Text, Token::Whitespace,
      Token::DoubleQuote, Token::Text, Token::DoubleQuote, Token::RightBracket,
      Token::Text, Token::LeftBracket, Token::Slash, Token::Text,
      Token::RightBracket, Token::Text
    ] do
      parser = Parser.new(nil)
      parser.tokenize('This \'and\' stuff [if "ok"] foo [/if] woo hoo')
      parser.tokens.map {|token| token.class }
    end
  end
  
  # Parser#commandify
  begin
    # left bracket present: handle_command
    expect Parser.new("", nil).to.receive(:handle_command) do |parser|
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.commandify
    end
    # left bracket present, but handle_command doesn't return a command
    expect true do
      parser = Parser.new("", nil)
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.stubs(:handle_command)
      stack = parser.stack
      parser.commandify
      parser.stack == stack
    end
    # left bracket present and handle_command returns BlockCommand
    expect Command::If do
      parser = Parser.new("", nil)
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.stubs(:handle_command).returns Command::If.new(nil, 'if', nil)
      parser.commandify
      parser.stack.last
    end
    # left bracket present and handle_command doesn't return BlockCommand
    expect Command do
      parser = Parser.new("", nil)
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.stubs(:handle_command).returns Command.new
      parser.commandify
      parser.stack.last.last
    end
    # text present
    expect [Command::Text, Command::Text] do
      parser = Parser.new("", nil)
      parser.stubs(:tokens).returns TokenList.new([Token::Text.new("foo"), Token::LeftBracket.new, Token::Text.new("bar") ])
      parser.stubs(:handle_command)
      parser.commandify
      parser.stack.last.commands.map {|cmd| cmd.class }
    end
    # stack is too big
    #expect RuntimeError do
    #  parser = Parser.new("", nil)
    #  parser.stubs(:tokens).returns(TokenList.new)
    #  parser.send(:instance_variable_set, "@stack", [ :template, :something_else ])
    #  parser.commandify
    #end
  end
  
  # Parser#handle_command
  begin
    # valid command
    expect :command do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(false)
      parser.stubs(:close_active_cmd).returns(false)
      parser.stubs(:lookup_command).returns(:command)
      parser.handle_command
    end
    # unknown command
    expect Command::Text do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args).raises(Lexicon::CommandNotFoundError)
      parser.handle_command
    end
    # modifier
    expect nil do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(true)
      parser.handle_command
    end
    # closer
    expect nil do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(false)
      parser.stubs(:close_active_cmd).returns(true)
      parser.handle_command
    end
    # reached end of list before end of command
    expect Command::Text do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args).raises(TokenList::EndOfListError)
      parser.handle_command
    end
    # unmatched single quote
    expect Command::Text do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnmatchedSingleQuoteError)
      parser.handle_command
    end
    # unmatched double quote
    expect Command::Text do
      parser = Parser.new("", nil)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnmatchedDoubleQuoteError)
      parser.handle_command
    end
  end
  
  # Parser#modify_active_cmd
  begin
    # active command is not a Command
    expect false do
      parser = Parser.new("", nil)
      parser.stubs(:stack).returns([ :not_a_command ])
      parser.modify_active_cmd("")
    end
    # active command is a Command but is not modified by given command
    expect false do
      parser = Parser.new("", nil)
      cmd = Command.new
      cmd.stubs(:modified_by?).returns(false)
      parser.stubs(:stack).returns([ cmd ])
      parser.modify_active_cmd("")
    end
    # active command is a Command and is modified by given command
    expect true do
      parser = Parser.new("", nil)
      cmd = Command.new
      cmd.stubs(:modified_by?).returns(true)
      parser.stubs(:stack).returns([ cmd ])
      parser.modify_active_cmd("")
    end
  end
  
  # Parser#close_active_cmd
  begin
    # active command is not a Command
    expect false do
      parser = Parser.new("", nil)
      parser.stubs(:stack).returns([ :not_a_command ])
      parser.close_active_cmd("")
    end
    # active command is a Command but is not closed by given command
    expect false do
      parser = Parser.new("", nil)
      cmd = Command.new
      cmd.stubs(:closed_by?).returns(false)
      parser.stubs(:stack).returns([ cmd ])
      parser.close_active_cmd("")
    end
    # active command is a Command and is closed by given command
    begin
      # stack should be popped
      expect 1 do
        parser = Parser.new("", nil)
        cmd = Command.new
        cmd.stubs(:closed_by?).returns(true)
        parser.stubs(:stack).returns([ [], cmd ])
        parser.close_active_cmd("")
        parser.stack.size
      end
      # active command should be moved to the one before it
      expect true do
        parser = Parser.new("", nil)
        cmd = Command.new
        cmd.stubs(:closed_by?).returns(true)
        parser.stubs(:stack).returns([ [], cmd ])
        parser.close_active_cmd("")
        parser.stack.first == [cmd]
      end
      # return value
      expect true do
        parser = Parser.new("", nil)
        cmd = Command.new
        cmd.stubs(:closed_by?).returns(true)
        parser.stubs(:stack).returns([ [], cmd ])
        parser.close_active_cmd("")
      end
    end
  end
  
  # Parser#gather_command_and_args
  begin
    # successfully parsed command: raw
    expect "[foo bar baz]" do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar"),
        Token::Whitespace.new(" "),
        Token::Text.new("baz"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
      cmd_call[:raw]
    end
    # successfully parsed command: full
    expect "foo bar baz" do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar"),
        Token::Whitespace.new(" "),
        Token::Text.new("baz"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
      cmd_call[:full]
    end
    # successfully parsed command: args
    expect ['bar', 'baz'] do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar"),
        Token::Whitespace.new(" "),
        Token::Text.new("baz"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
      cmd_call[:args]
    end
    # single quote found
    expect Parser.new("", nil).to.receive(:handle_quoted_arg).times(2) do |parser|
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::SingleQuote.new,
        Token::Text.new("bar"),
        Token::SingleQuote.new,
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
    end
    # double quote found
    expect Parser.new("", nil).to.receive(:handle_quoted_arg).times(2) do |parser|
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::DoubleQuote.new,
        Token::Text.new("bar"),
        Token::DoubleQuote.new,
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
    end
    # we reach end of token list before command ends
    expect TokenList::EndOfListError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.gather_command_name_and_args(cmd_call)
    end
    # UnmatchedSingleQuoteError is caught and re-thrown
    expect Parser::UnmatchedSingleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.stubs(:handle_quoted_arg).raises(Parser::UnmatchedSingleQuoteError)
      parser.gather_command_name_and_args(cmd_call)
    end
    # UnmatchedDoubleQuoteError is caught and re-thrown
    expect Parser::UnmatchedDoubleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list); tokens.next
      parser.stubs(:tokens).returns(tokens)
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      parser.stubs(:handle_quoted_arg).raises(Parser::UnmatchedDoubleQuoteError)
      parser.gather_command_name_and_args(cmd_call)
    end
  end
  
  # Parser#handle_quoted_arg
  begin
    # we reach closing single quote
    expect ['bar'] do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
        Token::Text.new("bar"),
        Token::SingleQuote.new("'"),
        Token::Whitespace.new(" "),
        Token::Text.new("baz"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::SingleQuote)
    end
    # we reach closing double quote
    expect ['bar'] do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::DoubleQuote.new('"'),
        Token::Text.new("bar"),
        Token::DoubleQuote.new('"'),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::DoubleQuote)
    end
    # we reach right bracket before we find closing single quote
    expect Parser::UnmatchedSingleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::DoubleQuote.new("'"),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::SingleQuote)
    end
    # we reach right bracket before we find closing double quote
    expect Parser::UnmatchedDoubleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::DoubleQuote.new('"'),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::DoubleQuote)
    end
    # we reach end of token list before we find closing single quote
    expect Parser::UnmatchedSingleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::SingleQuote)
    end
    # we reach end of token list before we find closing single quote
    expect Parser::UnmatchedDoubleQuoteError do
      parser = Parser.new("", nil)
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::DoubleQuote.new('"'),
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      parser.handle_quoted_arg(Token::DoubleQuote)
    end
    # left bracket reached
    expect Parser.new("", nil).to.receive(:handle_command) do |parser|
      list = [
        Token::LeftBracket.new("["),
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::DoubleQuote.new('"'),
        Token::LeftBracket.new("["),
        Token::Text.new("bar"),
        Token::RightBracket.new("]"),
        Token::DoubleQuote.new('"'),
        Token::RightBracket.new("]")
      ]
      tokens = TokenList.new(list)
      tokens.pos = 3
      parser.stubs(:tokens).returns(tokens)
      begin
        parser.handle_quoted_arg(Token::DoubleQuote)
      rescue Parser::UnmatchedDoubleQuoteError
      end
    end
  end
end