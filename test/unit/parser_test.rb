#
# FIXME
#

require File.dirname(__FILE__)+'/test_helper'

require 'papyrus'
require 'commands/if'

module Papyrus
  module Commands
    class SomeBlockCommand < BlockCommand
    end
  end
end

include Papyrus

require 'tempfile'

Expectations do
  
  # Parser.parse_file
  begin
    # file has not been parsed yet
    expect Parser.to.receive(:parse_and_cache_file).with("/source/file", {}, "/cached/file") do
      Parser.stubs(:find_template).returns("/source/file")
      Parser.stubs(:cached_path).returns("/cached/file")
      File.stubs(:exists?).returns(false)
      Parser.parse_file("", {})
    end
    # cache file exists, but source has been modified since being cached
    expect Parser.to.receive(:parse_and_cache_file).with("/source/file", {}, "/cached/file") do
      Parser.stubs(:find_template).returns("/source/file")
      Parser.stubs(:cached_path).returns("/cached/file")
      File.stubs(:exists?).returns(true)
      Parser.stubs(:file_mtime).returns(2)
      Parser.stubs(:cached_mtime).returns(1)
      Parser.parse_file("", {})
    end
    # cache file exists and source has not been modified since being cached
    expect Parser.to.receive(:read_cached).with("/cached/file") do
      Parser.stubs(:find_template).returns("/source/file")
      Parser.stubs(:cached_path).returns("/cached/file")
      File.stubs(:exists?).returns(true)
      Parser.stubs(:file_mtime).returns(1)
      Parser.stubs(:cached_mtime).returns(2)
      Parser.parse_file("", {})
    end
  end
  
  # Parser.find_template
  begin
    # foil attempts to get around template paths restriction
    # (this is not a very good test)
    expect File.to.receive(:exists?).with("./foo/bar") do
      Parser.send(:find_template, "../foo/bar")
    end
    # file is in template paths
    expect File.join(File.expand_path(File.dirname(__FILE__)), "foo/bar") do
      File.stubs(:exists?).returns(true)
      Parser.send(:find_template, "foo/bar")
    end
    # file is not in template paths
    expect nil do
      Parser.send(:find_template, "foo/bar")
    end
  end
  
  # Parser.cached_path
  begin
    expect "/foo/bar/baz" do
      Papyrus.stubs(:cached_template_dir).returns('/foo/bar')
      Parser.send(:cached_path, "/path/to/baz")
    end
  end
  
  # Parser.parse_and_cache_file
  begin
    # source should be read from and sent to Parser.parse
    expect Parser.to.receive(:parse).with("Some template content").returns(Template.new(nil)) do
      src = Tempfile.new("source")
      src.write("Some template content")
      src.close
      File.stubs(:write)
      Parser.send(:parse_and_cache_file, src.path, {}, "/cached/file")
    end
    # cached file should contain template output
    expect "Some template output" do
      File.stubs(:read)
      Parser.stubs(:parse)
      template = Template.new(nil)
      template.stubs(:output).returns("Some template output")
      Parser.stubs(:parse).returns(template)
      cached = Tempfile.new("cached")
      Parser.send(:parse_and_cache_file, "", [], cached.path)
      cached.read
    end
  end
  
  # Parser.new
  begin
    # @template
    expect Template do
      Parser.new("").send(:instance_variable_get, "@template")
    end
    # @stack
    expect true do
      parser = Parser.new("")
      parser.stack.is_a?(Array) && parser.stack.first.is_a?(Template)
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
      parser = Parser.new('This \'and\' stuff [if "ok"] foo [/if] woo hoo')
      parser.tokenize
      parser.tokens.map {|token| token.class }
    end
  end
  
  # Parser#populate_template
  begin
    # left bracket present: handle_command
    expect Parser.new("").to.receive(:handle_command).returns(Node.new) do |parser|
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.populate_template
    end
    # left bracket present, but handle_command doesn't return a command
    expect true do
      parser = Parser.new("")
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.stubs(:handle_command).returns(Node.new)
      stack = parser.stack
      parser.populate_template
      parser.stack == stack
    end
    # left bracket present and handle_command returns BlockCommand
    begin
      # we get the command back
      expect Commands::If do
        parser = Parser.new("")
        parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
        parser.stubs(:handle_command).returns Commands::If.new('if', [])
        parser.populate_template
        parser.stack.last
      end
      # the command knows where it is contextually
      expect Template do
        parser = Parser.new("")
        parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
        cmd = Commands::If.new('if', [])
        parser.stubs(:handle_command).returns(cmd)
        parser.populate_template
        parser.stack.last.parent
      end
    end
    # left bracket present and handle_command doesn't return BlockCommand
    expect Command do
      parser = Parser.new("")
      parser.stubs(:tokens).returns TokenList.new([Token::LeftBracket.new])
      parser.stubs(:handle_command).returns Command.new("", [])
      parser.populate_template
      parser.stack.last.last
    end
    # text present
    # perhaps not a sufficient test?
    expect [Text, Node, Text] do
      parser = Parser.new("")
      parser.stubs(:tokens).returns TokenList.new([Token::Text.new("foo"), Token::LeftBracket.new, Token::Text.new("bar") ])
      parser.stubs(:handle_command).returns(Node.new)
      parser.populate_template
      parser.stack.last.nodes.map {|cmd| cmd.class }
    end
  end
  
  # Parser#close_open_block_commands
  begin
    # unclosed block commands should be autoclosed at end
    expect Commands::SomeBlockCommand do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.send(:instance_variable_set, "@stack", [
        Template.new(parser),
        Commands::SomeBlockCommand.new("", [])
      ])
      parser.close_open_block_commands
      parser.stack.first.nodes.first
    end
  end
  
  # Parser#handle_command
  begin
    # end of command
    expect Parser.new("").to.receive(:handle_command_close) do |parser|
      tokens = TokenList.new([
        Token::Slash.new("/")
      ])
      parser.stubs(:tokens).returns(tokens)
      parser.handle_command
    end
    # valid command
    expect :command do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(false)
      parser.stubs(:close_active_cmd).returns(false)
      parser.stubs(:lookup_var_or_command).returns(:command)
      parser.handle_command
    end
    # unknown command
    expect Text do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnknownCommandError)
      parser.handle_command
    end
    # modifier should modify command and return empty output
    expect Text.new("") do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(true)
      parser.handle_command
    end
    # closer should end command and return empty output
    expect Text.new("") do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args)
      parser.stubs(:modify_active_cmd).returns(false)
      parser.stubs(:close_active_cmd).returns(true)
      parser.handle_command
    end
    # reached end of list before end of command
    expect Text do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnmatchedLeftBracketError)
      parser.handle_command
    end
    # unmatched single quote
    expect Text do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnmatchedSingleQuoteError)
      parser.handle_command
    end
    # unmatched double quote
    expect Text do
      parser = Parser.new("")
      parser.stubs(:tokens).returns(TokenList.new)
      parser.stubs(:gather_command_name_and_args).raises(Parser::UnmatchedDoubleQuoteError)
      parser.handle_command
    end
  end
  
  # Parser#close_active_cmd
  begin
    # command name is not a Text token
    expect Parser::InvalidEndOfCommandError do
      parser = Parser.new("")
      list = [ Token::Slash.new, Token::RightBracket.new ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.handle_command_close
    end
    # active command is not a BlockCommand
    expect Parser::InvalidEndOfCommandError do
      parser = Parser.new("")
      list = [ Token::Slash.new, Token::Text.new, Token::RightBracket.new ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.stubs(:stack).returns([ :not_a_command ])
      parser.handle_command_close
    end
    # active command is a BlockCommand but is not closed by given command
    expect Parser::InvalidEndOfCommandError do
      parser = Parser.new("")
      list = [ Token::Slash.new, Token::Text.new("bar"), Token::RightBracket.new ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.stubs(:stack).returns([ Commands::SomeBlockCommand.new("foo", []) ])
      parser.handle_command_close
    end
    # active command is a BlockCommand and is closed by given command
    begin
      # stack should be popped
      expect 1 do
        parser = Parser.new("")
        list = [ Token::Slash.new, Token::Text.new("foo"), Token::RightBracket.new ]
        parser.stubs(:tokens).returns TokenList.new(list)
        parser.stubs(:stack).returns([ [], Commands::SomeBlockCommand.new("foo", []) ])
        parser.handle_command_close
        parser.stack.size
      end
      # active command should be moved to the one before it
      expect true do
        parser = Parser.new("")
        list = [ Token::Slash.new, Token::Text.new("foo"), Token::RightBracket.new ]
        parser.stubs(:tokens).returns TokenList.new(list)
        cmd = Commands::SomeBlockCommand.new("foo", [])
        parser.stubs(:stack).returns([ [], cmd ])
        parser.handle_command_close
        parser.stack.first == [cmd]
      end
    end
    # right bracket never reached
    expect Parser::UnmatchedLeftBracketError do
      parser = Parser.new("")
      list = [ Token::Slash.new, Token::Text.new("foo") ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.stubs(:stack).returns([ [], Commands::SomeBlockCommand.new("foo", []) ])
      parser.handle_command_close
    end
  end  
  
  # Parser#modify_active_cmd
  begin
    # active command is not a BlockCommand
    expect false do
      parser = Parser.new("")
      parser.stubs(:stack).returns([ :not_a_command ])
      parser.modify_active_cmd("")
    end
    # active command is a BlockCommand but is not modified by given command
    expect false do
      parser = Parser.new("")
      cmd = Commands::SomeBlockCommand.new("", [])
      cmd.stubs(:modified_by?).returns(false)
      parser.stubs(:stack).returns([ cmd ])
      parser.modify_active_cmd("")
    end
    # active command is a BlockCommand and is modified by given command
    expect true do
      parser = Parser.new("")
      cmd = Commands::SomeBlockCommand.new("", [])
      cmd.stubs(:modified_by?).returns(true)
      parser.stubs(:stack).returns([ cmd ])
      parser.modify_active_cmd("")
    end
  end
  
  # Parser#lookup_var_or_command
  begin
    # when name is a variable in the active context
    expect Text.new("some text") do
      Papyrus.send(:instance_variable_set, "@lexicon", {})
      parser = Parser.new("")
      parser.stack.first.stubs(:vars).returns("foo" => "some text")
      parser.lookup_var_or_command("foo", [])
    end
    # when name is not in lexicon
    expect Parser::UnknownCommandError do
      Papyrus.send(:instance_variable_set, "@lexicon", {})
      parser = Parser.new("")
      parser.lookup_var_or_command("foo", [])
    end
    # when name is in lexicon
    expect Commands::If do
      Papyrus.send(:instance_variable_set, "@lexicon", { 'if' => Commands::If })
      parser = Parser.new("")
      parser.lookup_var_or_command("if", [])
    end
  end
  
  # Parser#gather_command_and_args
  begin
    # successfully parsed command: name and args
    expect ['foo', ['bar', 'baz']] do
      parser = Parser.new("")
      list = [
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar"),
        Token::Whitespace.new(" "),
        Token::Text.new("baz"),
        Token::RightBracket.new("]")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.gather_command_name_and_args
    end
    # single quote found
    expect Parser.new("").to.receive(:handle_quoted_arg).times(2) do |parser|
      list = [
        Token::Text.new("foo"),
        Token::SingleQuote.new,
        Token::Text.new("bar"),
        Token::SingleQuote.new,
        Token::RightBracket.new("]")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.gather_command_name_and_args
    end
    # double quote found
    expect Parser.new("").to.receive(:handle_quoted_arg).times(2) do |parser|
      list = [
        Token::Text.new("foo"),
        Token::DoubleQuote.new,
        Token::Text.new("bar"),
        Token::DoubleQuote.new,
        Token::RightBracket.new("]")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.gather_command_name_and_args
    end
    # we reach end of token list before command ends
    expect Parser::UnmatchedLeftBracketError do
      parser = Parser.new("")
      list = [
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::Text.new("bar")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.gather_command_name_and_args
    end
    # UnmatchedSingleQuoteError is caught and re-thrown
    expect Parser::UnmatchedSingleQuoteError do
      parser = Parser.new("")
      list = [
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.stubs(:handle_quoted_arg).raises(Parser::UnmatchedSingleQuoteError)
      parser.gather_command_name_and_args
    end
    # UnmatchedDoubleQuoteError is caught and re-thrown
    expect Parser::UnmatchedDoubleQuoteError do
      parser = Parser.new("")
      list = [
        Token::Text.new("foo"),
        Token::Whitespace.new(" "),
        Token::SingleQuote.new("'"),
        Token::Text.new("bar"),
        Token::RightBracket.new("]")
      ]
      parser.stubs(:tokens).returns TokenList.new(list)
      parser.stubs(:handle_quoted_arg).raises(Parser::UnmatchedDoubleQuoteError)
      parser.gather_command_name_and_args
    end
  end
  
  # Parser#handle_quoted_arg
  begin
    # we reach closing single quote
    expect ['bar'] do
      parser = Parser.new("")
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
      parser = Parser.new("")
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
      parser = Parser.new("")
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
      parser = Parser.new("")
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
      parser = Parser.new("")
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
      parser = Parser.new("")
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
    expect Parser.new("").to.receive(:handle_command) do |parser|
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