module Papyrus
  # The big ass compiler that does all the dirty work of turning
  # templates into compiled commands.
  #
  # Compiler.new() accepts a hash as an argument, and looks for these
  # keys: (with defaults)
  #
  #  'context' => A context object. (A new context)
  #  'lexicon'  => A Lexicon class singleton. (DefaultLexicon)
  #  'preprocessor' => The preprocessor. (DefaultPreprocessor)
  #  'default_processor' => The processor. (:process)
  #  'source' => The Source for templates. (FileSource)
  #
  # Once the compiler is created, it can compile and parse any number of
  # templates. 
  #
  # It can be treated as a one-template item by using
  # Compiler#load(template), and calling Compiler.output
  #
  # To create separate generated templates from the same engine, use
  # Compiler#parse, or Compiler#load. (It will still keep the most recent
  # one it's #load'd, but that will not affect previously parsed or
  # loaded)
  class Compiler
    attr_reader :options, :preprocessor, :default_processor, :lexicon, :source,
                :method_separator_regexp
    attr_reader :commands
    
    # Compiler.new() accepts a hash as an argument, and looks for these
    # keys: (with defaults)
    #
    #  
    #  :lexicon  => A Lexicon object. (a dup of DefaultLexicon)
    #  :context => A context object. (A new context)
    #  :preprocessor => The preprocessor. (DefaultPreprocessor)
    #  :default_processor => The processor. (:process)
    #  :source => The type of input ('file')
    def initialize(options = {})
      @options  = options.symbolize_keys
      @lexicon = options.delete(:lexicon) || DefaultLexicon
      @preprocessor = options.delete(:preprocessor) || DefaultPreprocessor
      @default_processor = options.delete(:default_processor) || :unescaped
      @method_separator_regexp = if seps = options.delete(:method_separators)
        re_seps = seps.map {|sep| Regexp.escape(sep) }
        /#{re_seps.join('|')}/
      else
        %r|[./]|
      end
      @source = (options.delete(:source) || FileSource).new(options)
      @commands = nil
    end
    
    # Loads +name+ from a template, and saves it to allow this compiler to
    # use it for output.
    def load(name)
      @commands = compile(name)
    end
    
    # Retrieves the content of the given file, if it exists, possibly passing
    # it through the tokenizer/compiler.
    def compile(name)
      if content = source.get(name)
        if content.kind_of?(Command::Base)
          content
        else
          template = Parser.new(@lexicon, @context).parse(content)
          source.cache(name, template) if source.respond_to?(:cache)
          template
        end
      else
        #template = Template.new(@options)
        #template << Command::Text.new("[ Template '#{name}' not found ]")
        #template
        raise "Template '#{name}' not found!"
      end
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
=begin
    # returns the output of the command, or the whole command if the conversion
    # was unsuccessful 
    def handle_command(input, output)
      unless input.exist?(/\]/)
        # command never ends, so stop parsing
        output += input.rest
        return
      end
      name = input.scan(/\w+/)
      call = CommandCall.new(@lexicon, name)
      if call.invalid_command?
        # stop parsing command
        output += input.scan_until(/\]/)
        return
      end
      while input.getch
        if c == "]"
          # done with command, so evaluate
          output += call.to_command
          break
        end
        call.whole_command += c
        case c
        when " "
          call.args << ""
        when "'", '"'
          unless rest = input.scan_until(/#{c}/)
            # invalid command, so stop parsing command
            output += input.scan_until(/\]/)
            return
          end
          call.args << c + rest
        when "["
          handle_command(input, arg)
        else
          call.args.last += c
        end
=end        
 
  end
end