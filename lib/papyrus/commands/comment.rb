module Papyrus
  module Commands
    # A Comment command is a command that just returns nothing for its
    # output, allowing the designer to populate their pages with
    # Papyrus-style comments as well.
    class Comment < Command
      # Save the +comment+ for to_s
      def initialize(*args)
        super
        @comment = @args.first
      end
      
      # output returns nothing.
      def output(context=nil)
        ''
      end
      
      def to_s
        "[ Comment: #{@comment} ]"
      end
    end
  end
end