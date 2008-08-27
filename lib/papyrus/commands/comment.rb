module Papyrus
  module Commands
    # A Comment command is a command that just returns nothing (well, an empty
    # string) for its output.
    class Comment < Command
      # Creates a new Comment, storing the given comment string (for inspection
      # purposes).
      def initialize(*args)
        super
        @comment = @args.first
      end
      
      # Returns an empty string.
      def output
        ""
      end
      
      def to_s
        "[ Comment: #{@comment} ]"
      end
    end
  end
end