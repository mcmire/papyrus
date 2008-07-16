class PageTemplate
  module Command
    # Command::Block provides a single interface to multiple Command objects.
    # This should probably never be called by the designer or a programmer,
    # but by Stackables.
    class Block < Base
      def initialize()
        @command_block = []
      end

      # Return Commands held, as a string
      def to_s
        '[ Blocks: ' + @command_block.map{ |i| "[#{i.to_s}]" }.join(' ') + ']'
      end

      # Returns the number of Commands held in this Block
      def length
        @command_block.length
      end

      # Adds +command+ to the end of the Block's chain of Commands.
      #
      # A TypeError is raised if the object being added is not a ((<Command>)).
      def add(command)
        unless command.is_a?(Command::Base)
          raise TypeError, 'Command::Block#add: Attempt to add non-Command object'
        end
        @command_block << command
      end

      # Calls Command#output(context) on each Command contained in this 
      # object.  The output is returned as a single string.  If no output
      # is generated, returns an empty string.
      def output(context = nil)
        @command_block.map{|x| x.output(context)}.join('')
      end
    end
  end
end