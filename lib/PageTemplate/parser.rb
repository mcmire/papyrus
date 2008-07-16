class PageTemplate
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
    attr_reader :preprocessor, :default_processor
    attr_reader :lexicon, :context, :source
    attr_reader :args, :commands, :method_separators

    # This is corny, but recent_parser returns the most recently created
    # Parser.
    def Parser.recent_parser
      @@recent_parser
    end
    # Parser.new() accepts a hash as an argument, and looks for these
    # keys: (with defaults)
    #
    #  'context' => A context object. (A new context)
    #  'lexicon'  => A Lexicon object. (a dup of DefaultLexicon)
    #  'preprocessor' => The preprocessor. (DefaultPreprocessor)
    #  'default_processor' => The processor. (:process)
    #  'source' => The Source for templates. (FileSource)
    def initialize(args = {})
      @context    = self
      @@recent_parser = self
      @args         = args # For sub-commands
      @parent       = args['context'] || nil
      if @parent
        unless @parent.is_a? Context then
          @parent = Context.construct_from(args['context'])
        end
      end
      @lexicon     = args['lexicon'] || DefaultLexicon
      @preprocessor = args['preprocessor'] || DefaultPreprocessor
      @default_processor = args['default_processor'] || :unescaped
      @method_separators = args['method_separators'] || './'
      @source       = (args['source'] || FileSource).new(@args)
      @commands     = nil
    end
    # Load +name+ from a template, and save it to allow this parser to
    # use it for output.
    def load(name)
      @commands = compile(name)
    end
    # Load +name+ from a template, but do not save it.
    def compile(name)
      body = @source.get(name)
      case
      when body.is_a?(Command)
        body
      when body
        cmds = parse(body)
        @source.cache(name,cmds) if @source.respond_to?(:cache)
        cmds
      else
        cmds = Template.new(self)
        cmds.add Command::Text.new("[ Template '#{name}' not found ]")
        cmds
      end
    end
    # Compile a Template (Command::Block) from a string. Does not save
    # the commands.
    def parse(body)
      rx = @lexicon.sub_regex
      stack = [Template.new(self)]
      stack[0].parent = self
      last = stack.last
      modifier = nil
      closer = nil
      while (m = rx.match(body))
        pre = m.pre_match
        command = m[1..-1].compact.first.strip.gsub(/\s+/,' ')
        body = m.post_match
        
        # Convert all pre-text to a Text command
        if (pre && pre.length > 0)
          stack.last.add Command::Text.new(pre)
        end

        # If the command at the top of the stack is a 'Stacker',
        # Does this command modify it? If so, just skip back.
        next if modifier && @lexicon.modifies?(modifier,last,command)

        # If it closes, we're done changing this. Pop it off the
        # Stack and add it to the one above it.
        if closer and @lexicon.modifies?(closer,last,command)
          cmd = stack.pop
          last = stack.last
          last.add(cmd)
          modifier = last.class.modifier
          closer = last.class.closer
          next
        end

        # Create the command
        cmd = @lexicon.lookup(command)
        
        # If it's a stacking command, push it on the stack
        if cmd.is_a?(Command::Stackable)
          modifier = cmd.class.modifier
          closer   = cmd.class.closer
          stack.push cmd
          last = cmd
        else
          last.add cmd
        end
      end
      stack.last.add Command::Text.new(body) if body && body.length > 0
      if (stack.length > 1)
        raise ArgumentError, 'Mismatched command closures in template'
      end
      stack[0]
    end

    # Since a Parser is also a context object, include ContextItem
    include ContextItem
    # But redefine parser
    def parser
      self
    end

    # Not really of any point, but clears the saved commands.
    def clearCommands
      @commands = nil
    end
    # If any commands are loaded and saved, return a string of it.
    def output(*args)
      return '' unless @commands
      @commands.output(*args)
    end
  end
end