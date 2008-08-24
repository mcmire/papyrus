module Papyrus
  class Parser
    class UnmatchedLeftBracketError < StandardError; end
    class UnmatchedSingleQuoteError < StandardError; end
    class UnmatchedDoubleQuoteError < StandardError; end
    class UnknownCommandError       < StandardError; end
    class InvalidEndOfCommandError  < StandardError; end
    
    class << self
      def parse_file(name, vars)
        file = find_template(name) or raise "Couldn't find template '#{name}'!"
        cached = cached_path(file)
        if Papyrus.cache_templates? and File.exists?(cached) && cached_mtime(cached) >= file_mtime(file)
          read_cached(cached)
        else
          parse_and_cache_file(file, vars, cached)
        end
      end
      
      def parse(content)
        new(content).parse
      end
      
    ## can't set private, otherwise Ruby complains the method's not there for some reason
    #private
      def find_template(name)
        name = name.gsub("../", "")
        for path in Papyrus.source_template_dirs
          file = File.join(path, name)
          file.untaint
          return File.expand_path(file) if File.exists?(file)
        end
        return nil
      end
      
      def cached_path(file)
        File.join(Papyrus.cached_template_dir, File.basename(file))
      end
      
      def cached_mtime(cached)
        File.mtime(cached)
      end
      
      def file_mtime(file)
        File.mtime(file)
      end
      
      def read_cached(cached)
        File.read(cached)
      end
      
      def parse_and_cache_file(file, vars, cached)
        content = File.read(file)
        template = parse(content)
        template.vars = vars
        output = template.output
        File.write(cached, output) if Papyrus.cache_templates?
        output
      end
    end
    
    attr_reader :content, :template
    attr_reader :stack, :tokens
    
    def initialize(content)
      Papyrus.load_command_classes
      @content = content
      @template = Template.new(self)
      @stack = [ @template ]
    end
    
    def parse
      tokenize
      make_template
      @template
    end
    
    def tokenize
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
    
    def make_template
      populate_template
      close_open_block_commands
    end
    
    def populate_template
      # we set the stack in the constructor b/c that works better for testing
      while token = tokens.advance
        case token
        when Token::LeftBracket
          cmd = handle_command
          (cmd.kind_of?(BlockCommand) ? stack : stack.last) << cmd if cmd
        else
          # we can safely assume token is a Token::Text
          stack.last << Text.new(token)
        end
      end
    end
    
    def close_open_block_commands
      return unless stack.size > 1
      # Oops, I guess we have BlockCommands that never ended.
      # That's okay, let's just end them manually.
      until stack.size == 1
        cmd = stack.pop
        stack.last << cmd
      end
    end
    
    # Returns a command if we're dealing with a command and it exists in the lexicon,
    # nil if we're dealing with a modifier of a command, or the raw command as a
    # Text command if we had a syntax error or unknown command.
    def handle_command
      tokens.start_stashing! # raw and full
      tokens.stash_curr # left bracket
      begin
        if tokens.next.is_a?(Token::Slash)
          handle_command_close
        else
          name, args = gather_command_name_and_args
          return Text.new("") if modify_active_cmd(name, args)
          lookup_var_or_command(name, args)
        end
      rescue UnmatchedLeftBracketError, UnmatchedSingleQuoteError,
             UnmatchedDoubleQuoteError, UnknownCommandError => e
        # assume we've reached the end of the command, so don't treat it as a command
        Text.new(tokens.cmd_info[:raw])
      ensure
        tokens.stop_stashing!
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
    
    def modify_active_cmd(name, args)
      active_cmd = stack.last
      (active_cmd.is_a?(BlockCommand) && active_cmd.modified_by?(name, args)) || false
    end
    
    def lookup_var_or_command(name, args)
      active_cmd = stack.last
      if (active_cmd.is_a?(BlockCommand) and val = active_cmd.active_block.get(name)) or val = active_cmd.get(name)
        Text.new(val)
      elsif command_klass = Papyrus.lexicon[name]
        command_klass.new(active_cmd, name, args)
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