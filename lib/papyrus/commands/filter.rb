module Papyrus
  module Commands
    # A Filter command filters the output of its block through a text filter
    #  [% filter :reverse %]
    #    This text will be filtered through the :reverse filter
    #  [% end %]
    class Filter < BlockCommand
      attr_accessor :filter, :nodes
      attr_reader :active_block
      
      def initialize(*args)
        super
        @filter = @args.first
        @active_block = @nodes = []
      end

      def output
        text = nodes.inject("") {|str, cmd| str << cmd.output; str }
        Papyrus::Filter.filter(@filter, text)
      end
    end
  end
end