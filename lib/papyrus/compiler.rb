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
    #  :context => A context object. (A new context)
    #  :preprocessor => The preprocessor. (DefaultPreprocessor)
    #  :default_processor => The processor. (:process)
    #  :source => The type of input ('file')
    def initialize(options = {})
      @options  = options.symbolize_keys
      @preprocessor = options.delete(:preprocessor) || DefaultPreprocessor
      @default_processor = options.delete(:default_processor) || :unescaped
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
        if content.kind_of?(Command)
          content
        else
          parse(name, content)
        end
      else
        #template = Template.new(@options)
        #template << Text.new("[ Template '#{name}' not found ]")
        #template
        raise "Template '#{name}' not found!"
      end
    end
    
    def parse(name, content)
      template = Parser.new.parse(content)
      source.cache(name, template) if source.respond_to?(:cache)
      template
    end
 
  end
end