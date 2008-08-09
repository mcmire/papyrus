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
      
      #puts "lexicon.commands:"
      #puts lexicon.commands.pretty_inspect
      #puts "lexicon.modifiers:"
      #puts lexicon.modifiers.pretty_inspect
      #exit
      
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
      stack = [ new_template ]
      # Find all commands in body, convert text to Text commands,
      # add them to a Template
      tokenize(body, stack)
      stack.first
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
    def tokenize(body, stack)
      regex = lexicon.command_regexp
      while (m = regex.match(body))
        before_command = m.pre_match
        raw_command = m[1..-1].compact.first.strip.gsub(/\s+/, ' ')
        handle_command(before_command, raw_command, stack)
        body = m.post_match  # update search area
      end
      
      # All subs should be in the stack. Shove any remaining text in a Text command
      # and add it to the command on active of the stack.
      add_text_as_command_to_active_cmd(body, stack)
      
      #puts "Stack: " + stack.map {|x| x.class }.inspect
      
      # Sanity check - stack should only have one element at this point
      raise ArgumentError, 'Mismatched command closures in template' if stack.size > 1
    end
    
    def handle_command(before_command, raw_command, stack)
      add_text_as_command_to_active_cmd(before_command, stack)
      modify_active_cmd(raw_command, stack) || close_active_cmd(raw_command, stack) || add_command_to_stack(raw_command, stack)
    end
    
    # Shoves all text before the command into a Text command and adds it to the
    # command on active of the stack.
    def add_text_as_command_to_active_cmd(text, stack)
      stack.last << Command::Text.new(text) unless text.blank?
    end
    
    # Determines whether or not @modifier is a modifier of the active command,
    # and if so, modifies the command.
    def modify_active_cmd(raw_command, stack)
      active_cmd = stack.last
      #puts "Parser#modify_active_cmd: Active command is a: #{active_cmd.class}"
      #puts "Parser#modify_active_cmd: Raw command: #{raw_command}"
      active_cmd.modified_by?(raw_command) || false
    end
    
    # Determines whether or not @closer is a closer of the active command, and if so,
    # modifies the command, then pops it off the stack and adds it to the one above it.
    def close_active_cmd(raw_command, stack)
      active_cmd = stack.last
      #puts "Parser#close_active_cmd: Active command is a: #{active_cmd.class}"
      #puts "Parser#close_active_cmd: Raw command: #{raw_command}"
      #puts "Parser#close_active_cmd: Stack: " + stack.map {|x| x.class }.inspect
      if active_cmd.closed_by?(raw_command)
        cmd = stack.pop
        stack.last << cmd
        true
      else
        false
      end
    end
    
    # Looks up the given command in the lexicon and gets the command object.
    # If the command is a Stackable, then we add to the stack, otherwise we add it
    # to the command on top of the stack.
    def add_command_to_stack(raw_command, stack)
      cmd = lexicon.lookup(raw_command)
      if cmd.kind_of?(Command::Stackable)
        #puts "Parser#add_command_to_stack: Command is a: #{cmd.class}"
        stack << cmd
      else
        stack.last << cmd
      end
    end
  end
end