module Papyrus
  module Commands
    # A Filter command runs the output of its block through a text filter.
    #
    # *Syntax*: [filter <i>filter_name</i>]...[/filter]
    #
    # === Example
    #
    #  [filter reverse]
    #    Here's some text that will be reversed when the command is evaluated
    #  [/filter]
    class Filter < BlockCommand
      attr_accessor :filter, :nodes
      attr_reader :active_block
      
      # Creates a new Filter command, storing the given filter name.
      def initialize(*args)
        super
        @filter = @args.first
        @active_block = @nodes = []
      end

      # Evaluates the NodeList and hands the resulting string off to Filter.filter
      # for filtering.
      def output
        text = nodes.inject("") {|str, cmd| str << cmd.output }
        Papyrus::Filter.filter(@filter, text)
      end
    end
  end
end