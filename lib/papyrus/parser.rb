module Papyrus
  class Parser
    class UnmatchedLeftBracketError < StandardError; end
    class UnmatchedSingleQuoteError < StandardError; end
    class UnmatchedDoubleQuoteError < StandardError; end
    class MisplacedQuoteError       < StandardError; end
    class UnknownCommandError       < StandardError; end
    class InvalidEndOfCommandError  < StandardError; end
    
    class << self
      # Finds the given template in the source template paths. The template (assuming
      # it can be found) will be parsed depending on whether Papyrus.cache_templates
      # is true and we have a cached version of the template, and the cached version
      # is returned. An error is raised if the template cannot be found.
      def parse_file(name, vars)
        file = find_template(name) or raise "Couldn't find template '#{name}'!"
        cached = cached_file(file)
        if Papyrus.cache_templates? and File.exists?(cached) && cached_mtime(cached) >= file_mtime(file)
          read_cached(cached)
        else
          parse_and_cache_file(file, vars, cached)
        end
      end
      
      # Runs the given content through the Parser, returning the evaluated content.
      # You can supply context variables that will be passed onto the Parser.
      def parse(content, vars={})
        new(content, vars).parse.output
      end
      
    ## can't set private, otherwise Ruby complains the method's not there for some reason
    
    private  
      # Searches for a file by the given name in the source template paths, returning
      # the full path of the file if one is found, or nil otherwise.
      def find_template(name)
        name = name.gsub("../", "")
        for path in Papyrus.source_template_paths
          file = File.join(path, name)
          file.untaint
          return File.expand_path(file) if File.exists?(file)
        end
        return nil
      end
      
      # Returns the path of the file to which the parsed version of the template
      # will be written when the template is cached.
      def cached_file(file)
        File.join(Papyrus.cached_template_path, File.basename(file))
      end
      
      # Returns the modified time of the given cached file.
      def cached_mtime(cached)
        File.mtime(cached)
      end
      
      # Returns the modified time of the given source file.
      def file_mtime(file)
        File.mtime(file)
      end
      
      # Reads the content of the given cached file.
      def read_cached(cached)
        File.read(cached)
      end
      
      # Reads the given source file, sends it through the parser, caching the output
      # if necessary. Returns the parsed output.
      def parse_and_cache_file(file, vars, cached)
        content = File.read(file)
        output = parse(content, vars)
        File.write(cached, output) if Papyrus.cache_templates?
        output
      end
    end
    
    attr_reader :content, :template, :tokens
    # Used to keep track of open BlockCommands. As a BlockCommand is encountered,
    # it's added to the stack. Nodes created while the command is open are
    # then added to its node list. When the command closes, it's then popped off
    # the stack.
    attr_reader :stack
    
    # Creates a new instance of a Parser, storing the given content and possibly
    # the given context variables. Command classes will be loaded if they have not
    # already been done so.
    def initialize(content, vars={})
      Papyrus.load_command_classes
      @content = content
      @template = Template.new(self, vars)
      @stack = [ @template ]
    end
    
    # Tokenizes the stored content and creates a Template object from the produced
    # token list. Returns the Template object.
    def parse
      tokenize
      make_template
      @template
    end
    
  private
    
    # Splits the content into tokens by stepping the input through one character at
    # a time and categorizing each character. Basically, anything that's not a quote,
    # bracket or slash character will be grouped together. The resulting token list
    # is stored in @tokens.
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
    
    # Hey, you look like a smart pup. Why don't you give this a shot.
    def make_template
      populate_template
      close_open_block_commands
    end
    
    # Stepping through the token list, we create a Command object for anything that
    # looks like a command, or a Text node otherwise, and add it to the stack, thereby
    # populating it. BlockCommands are pushed onto the stack, while everything else
    # is added to whatever's on top of the stack (which will be a BlockCommand or
    # the Template object).
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
    
    # If any BlockCommands weren't closed properly, we just end them manually.
    def close_open_block_commands
      return unless stack.size > 1
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
          lookup_var_or_command(name, args, tokens.stash[:raw])
        end
      rescue UnmatchedLeftBracketError, UnmatchedSingleQuoteError,
             UnmatchedDoubleQuoteError, UnknownCommandError => e
        # assume we've reached the end of the command, so don't treat it as a command
        Text.new(tokens.stash[:raw])
      ensure
        tokens.stop_stashing!
      end
    end
    
    # Assuming we've already hit a left bracket and slash, pops off the command on
    # top of the stack if it looks like that command is being closed.
    #
    # An InvalidEndOfCommandError is raised if we hit the end of the token list
    # and the open command is never closed.
    #
    # An UnmatchedLeftBracketError is raised if we hit the end of the token list
    # before reaching a right bracket. 
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
    
    # If the given name doesn't refer to a command but just modifies the command
    # on top of the stack (assuming it's a BlockCommand), returns true, otherwise
    # returns false.
    def modify_active_cmd(name, args)
      active_cmd = stack.last
      (active_cmd.is_a?(BlockCommand) && active_cmd.modified_by?(name, args)) || false
    end
    
    # Looks up the given name in the global list of commands. If such a command exists,
    # returns a new instance of the command class. If we can't find the command but
    # there were no args passed to the command, returns a Variable node.
    #
    # Raises an UnknownCommandError if we can't find the command and args is not empty.
    def lookup_var_or_command(name, args, raw_command)
      active_cmd = stack.last
      if command_klass = Papyrus.lexicon[name]
        command_klass.new(active_cmd, name, args)
      elsif args.empty?
        Variable.new(active_cmd, name, raw_command)
      else
        raise UnknownCommandError
      end
    end
    
    # Assuming that we've already hit a left bracket, gets the name of the command
    # and then steps through the following tokens to get the arguments of the command.
    # Arguments enclosed in quotes will be properly grouped together.
    #
    # An UnmatchedSingleQuote or UnmatchedDoubleQuoteError will be raised if we've
    # hit an opening quote mark and we hit the end of the token list before reaching
    # a closing quote mark.
    #
    # An UnmatchedLeftBracketError will be raised if we hit the end of the token list
    # before reaching a right bracket.
    def gather_command_name_and_args
      name = tokens.advance
      args = []
      error = nil
      reached_eoc = false
      while token = tokens.advance
        case token
        when Token::LeftBracket
          args << handle_command
        when Token::RightBracket
          reached_eoc = true
          break
        when Token::SingleQuote, Token::DoubleQuote
          begin
            args << handle_quoted_arg
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
    
    # Assuming that we've already hit an opening quote mark, steps through the 
    # following tokens to collect the tokens before the closing quote mark.
    # If we encounter a command within the argument, that's handled appropriately.
    #
    # Raises an UnmatchedSingleQuoteError or UnmatchedDoubleQuoteError if we hit
    # the end of the token list before reaching a closing quote mark.
    def handle_quoted_arg
      raise MisplacedQuoteError unless tokens.prev.is_a?(Token::Whitespace)
      quote_klass = tokens.curr.class
      arg = []
      # push a dummy value onto the stack in case the top of the stack is a
      # BlockCommand and we come across, say, 'else' - we don't want that
      # interpreted as a modifier
      stack << Command.new(stack.last, "", [])
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
      raise unmatched_error unless reached_eoq
      arg
    ensure
      stack.pop
    end
    
  end
end