module Papyrus
  module Token
    class Base < ::String
      def to_s
        String.new(self)
      end
    end
    class DoubleQuote < Base; end
    class SingleQuote < Base; end
    class LeftBracket < Base; end
    class RightBracket < Base; end
    class Slash < Base; end
    class Whitespace < Base; end
    class Text < Base; end
  
    def self.create(text)
      klass = case text
        when '"'    then DoubleQuote
        when "'"    then SingleQuote
        when "["    then LeftBracket
        when "]"    then RightBracket
        when "/"    then Slash
        when /^\s$/ then Whitespace
        else             Text
      end
      klass.new(text)
    end
  end
  
  class TokenList < ::Array
    class EndOfListError < StandardError; end
    
    attr_accessor :pos
    attr_accessor :raise_eol_error, :skip_whitespace
    
    def initialize(array = [])
      super(array)
      @pos = -1
      @raise_eol_error = false
    end
    
    def next
      @pos += 1
      tok = self[@pos]
      raise EndOfListError if @raise_eol_error && @pos > self.size-1
      tok
    end
    
    def next_nonwhitespace
      tok = nil
      begin; tok = self.next; end while tok.is_a?(Token::Whitespace)
      tok
    end
    
    def curr
      self[@pos]
    end
    
    def prev
      self[@pos-1]
    end
    
    def save
      # ...
    end
    
    def revert
      # ...
    end
  end
  
  class Parser
    class UnmatchedSingleQuoteError < StandardError; end
    class UnmatchedDoubleQuoteError < StandardError; end
    
    # Parser is a context object
    include ContextItem
    
    @@recent_parser = nil
    
    class << self
      # Returns the most recently created Parser
      def recent_parser
        @@recent_parser
      end
    end
    
    attr_reader :lexicon, :context
    attr_reader :tokens, :stack
    
    # lexicon  => A Lexicon object. (a dup of DefaultLexicon)
    # context  => A context object. (A new context)
    def initialize(lexicon, parent=nil)
      @@recent_parser = self
      @context = self
      if parent
        @parent = parent.is_a?(ContextItem) ? parent : Context.construct_from(parent)
      end
      @parser = self
      @lexicon = lexicon
      @stack = [ Template.new(self) ]
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
    # - Stackable command not ended before eos: fudge end
    # - Unknown command name: treat as text
    def commandify
      # we set the stack in the constructor instead of here for testing purposes
      while token = tokens.next
        case token
        when Token::LeftBracket
          cmd = handle_command
          if cmd.kind_of?(Command::Base)
            # create new Context if Stackable command
            (cmd.kind_of?(Command::Stackable) ? stack : stack.last) << cmd
          end
        else
          # assume token is a Token::Text
          stack.last << Command::Text.new(token)
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
      cmd_call = { :full => "", :raw => "", :name => nil, :args => [] }
      begin
        gather_command_name_and_args(cmd_call)
        return if modify_active_cmd(cmd_call[:full])
        return if close_active_cmd(cmd_call[:full])
        lookup_command(cmd_call[:name], cmd_call[:args])
      rescue TokenList::EndOfListError, Lexicon::CommandNotFoundError,
             UnmatchedSingleQuoteError, UnmatchedDoubleQuoteError => e
        # assume we've reached the end of the command, so don't treat it as a command
        Command::Text.new(cmd_call[:raw])
      end
    end
    
    def modify_active_cmd(full_command)
      active_cmd = stack.last
      (active_cmd.is_a?(Command::Base) && active_cmd.modified_by?(full_command)) || false
    end
    
    def close_active_cmd(full_command)
      active_cmd = stack.last
      if active_cmd.is_a?(Command::Base) && active_cmd.closed_by?(full_command)
        cmd = stack.pop
        stack.last << cmd
        true
      else
        false
      end
    end
    
    def lookup_command
      lexicon.lookup(name, args)
    end
    
    def gather_command_name_and_args(cmd_call)
      curr = tokens.curr # left bracket
      cmd_call[:raw]  += curr
      name = tokens.next_nonwhitespace
      cmd_call[:name]  = name
      cmd_call[:raw]  += name
      cmd_call[:full] += name
      error = nil
      reached_eoc = false
      while token = tokens.next
        cmd_call[:raw] += token
        if token.is_a?(Token::RightBracket)
          reached_eoc = true
          break
        end
        cmd_call[:full] += token
        next if token.is_a?(Token::Whitespace)
        if token.is_a?(Token::SingleQuote) || token.is_a?(Token::DoubleQuote)
          begin
            cmd_call[:args] << handle_quoted_arg(token.class)
          rescue UnmatchedSingleQuoteError, UnmatchedDoubleQuoteError => error
            # keep going until we reach the end of the command or the token list
          end
        else
          cmd_call[:args] << token
        end
      end
      raise error if error
      raise TokenList::EndOfListError unless reached_eoc
    end
    
    def handle_quoted_arg(quote_klass)
      arg = []
      # push a dummy value onto the stack in case the top of the stack is a
      # Stackable and we come across, say, 'else' - we don't want that
      # interpreted as a modifier
      # TODO: Test?
      stack.last << Command::Base.new
      reached_eoq = false
      unmatched_error = (quote_klass == Token::SingleQuote) ? UnmatchedSingleQuoteError : UnmatchedDoubleQuoteError
      while token = tokens.next
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