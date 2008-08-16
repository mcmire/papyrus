module Papyrus
  # A Value command will print out a variable name, possibly passing its
  # value through a preprocessor.
  #
  # [% var variable [:processor] %]
  #
  # +variable+ is first plucked out of the Context,
  #
  # The to_s of the output from Context#get is passed through
  # parser's preprocessor. If :processor is defined, then 
  # parser.preprocessor.send(:processor,body) is called. This allows the
  # designer to choose a particular format for the output. If
  # :processor is not given, then parser's default processor is used.
  class Variable < Node

    # Creates an instance of Variable.
    #
    # +value+ is the name of the variable whose value will be fetched from the
    # context when the command is output; +processor+ is the name of the filter
    # (specifically, the method in the Preprocessor tied to the context) that will
    # be applied on the text.
    def initialize(name, processor)
      @name = name
      @processor = processor
    end

    # Requests the value of this object's saved value name from 
    # +context+, and returns the string representation of that
    # value to the caller, after passing it through the preprocessor.
    #---
    # Update to use Preprocessor instead of Commands::Filter?
    def output(context = nil)
      Commands::Filter.filter(context, @processor, self.class) {|cxt| cxt[@name] }
    end

    def to_s
      str = "[ Variable: #{@name} "
      str << ":#{@processor} " unless @processor.blank?
      str << ']'
      str
    end
  end
end