module PageTemplate
  module Command
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
    class Value < Base

      # Creates an instance of Command::Value.
      #
      # +value+ is the name of the variable whose value will be fetched from the
      # context when the command is output; +processor+ is the name of the filter
      # (specifically, the method in the Preprocessor tied to the context) that will
      # be applied on the text.
      def initialize(lexicon, called_as, value, processor=nil)
        super
        @value = value
        @processor = processor
      end

      # Requests the value of this object's saved value name from 
      # +context+, and returns the string representation of that
      # value to the caller, after passing it through the preprocessor.
      def output(context = nil)
        Filter.filter(context, @processor, self.class) {|cxt| cxt[@value] }
      end

      def to_s
        str = "[ Value: #{@value} "
        str << ":#{@processor} " if @processor
        str << ']'
        str
      end
    end
  end
end