class PageTemplate
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

      # Creates the Value, with +value+ as the name of the variable
      # to be inserted during output. +parser+ is the Parser object,
      # which we save so we can access its Preprocessor and its default
      # preprocessor
      def initialize(value,preprocessor)
        @value = value
        @processor = preprocessor
      end

      # Requests the value of this object's saved value name from 
      # +context+, and returns the string representation of that
      # value to the caller, after passing it through the preprocessor.
      def output(context = nil)
        parser = context.parser if context
        parser = Parser.recent_parser unless parser
        context ||= parser
        preprocessor = parser.preprocessor
        processor = @processor || parser.default_processor
        if preprocessor.respond_to?(processor)
          preprocessor.send(processor,context.get(@value).to_s)
        else
          "[ Command::Value: unknown preprocessor #{@processor} ]"
        end
      end

      def to_s
        str = "[ Value: #{@value} "
        str << ":#{@processor} " if (@processor)
        str << ']'
        str
      end
    end
  end
end