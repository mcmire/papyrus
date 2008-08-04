module PageTemplate
  module Command
    # A Comment command is a command that just returns nothing for its
    # output, allowing the designer to populate their pages with
    # PageTemplate-style comments as well.
    class Comment < Base
      # Save the +comment+ for to_s
      def initialize(called_as, comment='')
        super
        @comment = comment
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