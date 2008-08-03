module PageTemplate
  # The big ass parser that does all the dirty work of turning
  # templates into compiled commands.
  #
  # Parser.new() accepts a hash as an argument, and looks for these
  # keys: (with defaults)
  #
  #  'context' => A context object. (A new context)
  #  'lexicon'  => A Lexicon class singleton. (DefaultLexicon)
  #  'preprocessor' => The preprocessor. (DefaultPreprocessor)
  #  'default_processor' => The processor. (:process)
  #  'source' => The Source for templates. (FileSource)
  #
  # Once the parser is created, it can compile and parse any number of
  # templates. 
  #
  # It can be treated as a one-template item by using
  # Parser#load(template), and calling Parser.output
  #
  # To create separate generated templates from the same engine, use
  # Parser#parse, or Parser#load. (It will still keep the most recent
  # one it's #load'd, but that will not affect previously parsed or
  # loaded)
  class Parser
    @@recent_parser = nil
    
    attr_reader :preprocessor, :default_processor
    attr_reader :lexicon, :context, :source
    attr_reader :options, :commands, :method_separator_regexp

    # This is corny, but recent_parser returns the most recently created
    # Parser.
    def self.recent_parser
      @@recent_parser
    end
    
    # Parser is a context object
    include ContextItem
    
    # Parser.new() accepts a hash as an argument, and looks for these
    # keys: (with defaults)
    #
    #  :context => A context object. (A new context)
    #  :lexicon  => A Lexicon object. (a dup of DefaultLexicon)
    #  :preprocessor => The preprocessor. (DefaultPreprocessor)
    #  :default_processor => The processor. (:process)
    #  :source => The type of input ('file')
    def initialize(options = {})
      @options  = options.symbolize_keys
      @context = self
      @@recent_parser = self
      @parser = self
      @options = options # For sub-commands
      if context = options.delete(:context)
        # should this be context.is_a?(ContextItem) ?
        @parent = context.is_a?(Context) ? context : Context.construct_from(context)
      end
      @lexicon = options.delete(:lexicon) || DefaultLexicon
      @preprocessor = options.delete(:preprocessor) || DefaultPreprocessor
      @default_processor = options.delete(:default_processor) || :unescaped
      @method_separator_regexp = if seps = options.delete(:method_separators)
        re_seps = seps.map {|sep| Regexp.escape(sep) }
        /#{re_seps.join('|')}/
      else
        %r|[./]|
      end
      @source = (options.delete(:source) || FileSource).new(@options)
      @commands = nil
    end
    
    # Loads +name+ from a template, and saves it to allow this parser to
    # use it for output.
    def load(name)
      @commands = compile(name)
    end
    
    # Loads +name+ from a template, but does not save it.
    def compile(name)
      if body = @source.get(name)
        if body.kind_of?(Command::Base)
          body
        else
          template = parse(body)
          @source.cache(name, template) if @source.respond_to?(:cache)
          template
        end
      else
        template = new_template
        template << Command::Text.new("[ Template '#{name}' not found ]")
        template
      end
    end
    
    # Compile a Template (Command::Block) from a string.
    # Does not save the commands.
    def parse(body)
      @stack = [ new_template ]
      @top = stack.last
      @modifier = nil
      @closer = nil
      # Find all commands in body, convert text to Text commands,
      # add them to a Template
      tokenize(body)
      @stack.first
    end
    
    # Creates a new Template which knows this Parser instance as its parser.
    def new_template
      Template.new(self)
    end

    # Not really of any point, but clears the saved commands.
    def clear_commands
      @commands = nil
    end
    
    # If any commands are loaded and saved, return a string of it.
    def output(*args)
      return '' unless @commands
      @commands.output(*args)
    end
    
  private
    # for testing purposes
    attr_accessor :stack, :top, :modifier, :closer
  
    def tokenize(body)
      regex = @lexicon.command_regex
      while (m = regex.match(body))
        before_command = m.pre_match
        raw_command = m[1..-1].compact.first.strip.gsub(/\s+/, ' ')
        handle_command(before_command, raw_command)
        body = m.post_match  # update search area
      end
      
      # All subs should be in the stack. Shove any remaining text in a Text command
      # and add it to the command on top of the stack.
      add_text_as_command_to_top(body)
      
      # Sanity check - stack should only have one element at this point
      raise ArgumentError, 'Mismatched command closures in template' if @stack.size > 1
    end
    
    def handle_command(before_command, raw_command)
      # Shove all text before the command into a Text command and add it to the
      # command on top of the stack.
      add_text_as_command_to_top(before_command)

      # Assuming the command on top of the stack is Stackable, does this command
      # modify it? If so, just skip back.
      return if command_modifies_top_command?(raw_command)

      # If the command on top of the stack closes, we're done modifying this.
      # Pop it off the stack and add it to the one above it.
      return if command_closed_top_command?(raw_command)
      
      # Look up this command in the lexicon and get the command object.
      # If the command is Stackable, then add it to the stack, otherwise add it
      # to the command on top of the stack.
      add_command_to_stack(raw_command)
    end
    
    def add_text_as_command_to_top(text)
      @stack.last << Command::Text.new(text) unless text.blank?
    end
    
    def command_modifies_top_command?(raw_command)
      (@modifier && @lexicon.modifies?(@modifier, @top, raw_command)) || false
    end
    
    def command_closed_top_command?(raw_command)
      if @closer and @lexicon.modifies?(@closer, @top, raw_command)
        cmd = @stack.pop
        @top = @stack.last
        @top << cmd
        @modifier = @top.class.modifier
        @closer = @top.class.closer
        true
      else
        false
      end
    end
    
    def add_command_to_stack(raw_command)
      cmd = @lexicon.lookup(raw_command)
      if cmd.kind_of?(Command::Stackable)
        @modifier = cmd.class.modifier
        @closer   = cmd.class.closer
        @stack << cmd
        @top = cmd
      else
        @top << cmd
      end
    end
  end
end