module PageTemplate
  module Command
    # Command::Stackable is the parent class of any command that creates a
    # branch in the logic: such as If, Loop, etcetera.
    #
    # Any child that wants to do more than stand alone must inherit from
    # Stackable. We recommend setting @called_as, so all of Stackable's
    # ways of closing blocks work.
    class Stackable < Base
      self.closer = :end

      # @called_as is set to the command which this is called as. This
      # allows a number of [% end %], [% end name %], [% endname %] or
      # even [% /name %] to close Stackables.
      def initialize(*args)
        raise ArgumentError, 'Command::Stackable.new should not be called directly' if self.class == Stackable
        super
      end
      
      def add(block)
        raise ArgumentError, 'Command::Stackable#add should not be called directly'
      end
      def <<(cmd)
        add(cmd)
      end
      
      def end
      end
      
      def to_s
        "[ #{@called_as} ]"
      end
    end
  end
end