module PageTemplate
  module Command
    # A Filter command filters its block through a preprocessor
    #  [% filter :processor %]
    #    This text will be filtered through the :processor filter
    #  [% end %]
    class Filter < Stackable
      self.closer = :end
      
      # XXX: Hmm, I'm not so sure these should go here. This might be a better place
      # for Preprocessor.
      class << self
        def filter(context, processor, klass, &block)
          context, preprocessor, processor = get_processing_components(context, @processor)
          if preprocessor.respond_to?(processor)
            text = block.call(context)
            preprocessor.send(processor, text)
          else
            "[ #{klass}: unknown preprocessor '#{processor}' in #{preprocessor} ]"
          end
        end
      
      #private  # for some reason this messes up tests
        def get_processing_components(context, processor)
          context, parser = get_context_and_parser(context)
          preprocessor = parser.preprocessor
          processor ||= parser.default_processor
          [ context, preprocessor, processor ]
        end
        
        def get_context_and_parser(context)
          if context
            parser = context.parser
          else
            parser = context = Parser.recent_parser
          end
          [ context, parser ]
        end
      end
      
      def initialize(lexicon, called_as, processor)
        super
        @processor = processor
        @text = []
      end

      def add(cmd)
        @text << cmd
        self
      end

      def output(context=nil)
        self.class.filter(context, @processor, self.class) do |cxt|
          @text.inject("") {|str, cmd| str << cmd.output(cxt); str }
        end
      end
      
    end
  end
end