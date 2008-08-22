module Papyrus
  module Commands
    # A Filter command filters the output of its block through a text filter
    #  [% filter :reverse %]
    #    This text will be filtered through the :reverse filter
    #  [% end %]
    class Filter < BlockCommand
      attr_accessor :filter, :nodes
      
      def initialize(*args)
        super
        @filter = @args.first
        @nodes = []
      end

      def add(node)
        @nodes << node
        self
      end

      def output(context=nil)
        text = nodes.inject("") {|str, cmd| str << cmd.output(context); str }
        Papyrus::Filter.filter(@filter, text)
      end
    end
  end
end