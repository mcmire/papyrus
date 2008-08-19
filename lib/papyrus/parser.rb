module Papyrus
  class Parser
    class UnmatchedLeftBracketError < StandardError; end
    class UnmatchedSingleQuoteError < StandardError; end
    class UnmatchedDoubleQuoteError < StandardError; end
    class UnknownCommandError       < StandardError; end
    class InvalidEndOfCommandError  < StandardError; end
    
    attr_reader :template, :tokens, :stack
    
    def initialize
      @template = Template.new(self)
      @stack = [ @template ]
    end
    
    def parse(content)
      tokenize(content)
      commandify
    end
    
    def tokenize(content)
      @tokens = TokenList.new
      tok = nil
      brackets_open = 0
      for i in 0...content.length
        c = content[i].chr
        brackets_open += 1 if c == "["
        if brackets_open == 0
          # not in command, nothing special here
          (tok ||= Token::Text.new) << c
        else        
          case c
          when '"', "'", "[", "]", "/"
            @tokens << tok if tok
            tok = nil
            @tokens << Token.create(c)
          else
            is_whitespace = (c =~ /\s/)
            if tok and ((is_whitespace and tok.is_a? Token::Whitespace) or (!is_whitespace and tok.is_a? Token::Text))
              tok << c
            else
              @tokens << tok if tok
              tok = Token.create(c)
            end
          end
        end
        brackets_open -= 1 if c == "]"
      end
      @tokens << tok if tok
    end
    
    # Errors that can occur:
    # - Unmatched left bracket before eos: treat as text
    # - Extra right bracket(s): treat as text
    # - Unmatched double quote before eos: treat as text
    # - Unmatched single quote before eos: treat as text
    # - BlockCommand command not ended before eos: fudge end
    # - Unknown command name: treat as text
    def commandify
      # we set the stack in the constructor instead of here for testing purposes
      while token = tokens.advance
        case token
        when Token::LeftBracket
          cmd = handle_command
          if cmd.kind_of?(Command::BlockCommand)
            # create new context
            cmd.parent = stack.last
            stack << cmd
          else
            stack.last << cmd
          end
        else
          # assume token is a Token::Text
          stack.last << Text.new(token)
        end
      end
      # this is actually never supposed to happen...
      #raise "Too many items on stack" unless stack.size == 1
      stack.last
    end
    
    # Returns a command if we're dealing with a command and it exists in the lexicon,
    # nil if we're dealing with a modifier of a command, or the raw command as a
    # Text command if we had a syntax error or unknown command.
    def handle_command
      tokens.start_recording!
      begin
        if tokens.next.is_a?(Token::Slash)
          handle_command_close
        else
          name, args = gather_command_name_and_args
          return Text.new("") if modify_active_cmd(tokens.cmd_info[:full]) or close_active_cmd(tokens.cmd_info[:raw])
          lookup_var_or_command(name, args)
        end
      rescue UnmatchedLeftBracketError, UnmatchedSingleQuoteError,
             UnmatchedDoubleQuoteError, UnknownCommandError => e
        # assume we've reached the end of the command, so don't treat it as a command
        Text.new(tokens.cmd_info[:raw])
      ensure
        tokens.stop_recording!
      end
    end
    
    def handle_command_close
      tokens.advance # slash
      command_name = tokens.advance
      active_cmd = stack.last
      if command_name.is_a?(Token::Text) && active_cmd.is_a?(BlockCommand) && active_cmd.name == command_name
        cmd = stack.pop
        stack.last << cmd
        # get the rest of the command
        reached_eoc = false
        while token = tokens.advance
          if token.is_a?(Token::RightBracket)
            reached_eoc = true
            break
          end
        end
        raise UnmatchedLeftBracketError unless reached_eoc
      else
        raise InvalidEndOfCommandError
      end
    end
    
    def modify_active_cmd(full_command)
      active_cmd = stack.last
      (active_cmd.is_a?(BlockCommand) && active_cmd.modified_by?(full_command)) || false
    end
    
    def lookup_var_or_command(name, args)
      active_cmd = stack.last
      if val = active_cmd.get(name)
        Text.new(val)
      elsif command_klass = Papyrus.lexicon[name]
        command_klass.new(name, args)
      else
        raise UnknownCommandError
      end
    end
    
    def gather_command_name_and_args
      name = tokens.advance
      args = []
      error = nil
      reached_eoc = false
      while token = tokens.advance
        case token
        when Token::RightBracket
          reached_eoc = true
          break
        when Token::SingleQuote, Token::DoubleQuote
          begin
            args << handle_quoted_arg(token.class)
          rescue UnmatchedSingleQuoteError, UnmatchedDoubleQuoteError => error
            # keep going until we reach the end of the command or the token list
          end
        else
          args << token
        end
      end
      raise error if error
      raise UnmatchedLeftBracketError unless reached_eoc
      [name, args]
    end
    
    def handle_quoted_arg(quote_klass)
      arg = []
      # push a dummy value onto the stack in case the top of the stack is a
      # BlockCommand and we come across, say, 'else' - we don't want that
      # interpreted as a modifier
      # TODO: Test?
      stack.last << Command.new("", [])
      reached_eoq = false
      unmatched_error = (quote_klass == Token::SingleQuote) ? UnmatchedSingleQuoteError : UnmatchedDoubleQuoteError
      while token = tokens.advance
        case token
        when quote_klass
          reached_eoq = true
          break
        when Token::LeftBracket
          arg << handle_command
        when Token::RightBracket
          break
        else
          arg << token
        end
      end
      stack.pop
      raise unmatched_error unless reached_eoq
      arg
    end
    
  end
end