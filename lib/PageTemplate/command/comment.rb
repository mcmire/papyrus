class PageTemplate
  module Command
    # A Comment command is a command that just returns nothing for its
    # output, allowing the designer to populate their pages with
    # PageTemplate-style comments as well.
    class Comment < Base
      # output returns nothing.
      def output(context=nil)
        ''
      end
      # Save the +comment+ for to_s
      def initialize(comment='')
        @comment = comment
      end
      def to_s
        "[ Comment: #{@comment} ]"
      end
    end
  end
end