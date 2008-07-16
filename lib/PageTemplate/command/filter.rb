class PageTemplate
  module Command
    # A Filter command filters its block through a preprocessor
    #  [% filter :processor %]text[% end %]
    class Filter < Stackable
      @closer = :end
      def initialize(filter)
        @called_as = "filter"
        @processor = filter
        @text = []
      end

      def add(line)
        @text.push(line)
      end

      def output(context=nil)
        parser = context.parser if context
        parser = Parser.recent_parser unless parser
        context ||= parser
        preprocessor = parser.preprocessor
        processor = @processor || parser.default_processor
        text = ""
        @text.each { |c| text += c.output(context) }
        if preprocessor.respond_to?(processor)
          preprocessor.send(processor, text)
        else
          "[ Command::Value: unknown preprocessor #{@processor} ]"
        end
      end
    end
  end
end