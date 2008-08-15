module Papyrus
  module Command
    # Command::Block provides a single interface to multiple Command objects.
    # This should probably never be called by the designer or a programmer,
    # but by Stackables.
    class Block < Base
      attr_reader :commands
      
      def initialize(*args)
        super
        @commands = []
      end
      
      for meth in [ :length, :size, :first, :last, :empty? ]
        class_eval <<-EOT, __FILE__, __LINE__
          def #{meth}
            @commands.send(:#{meth})
          end
        EOT
      end
      def [](i)
        @commands[i]
      end

      # Adds +command+ to the end of the Block's chain of Commands.
      # A TypeError is raised if the object being added is not a ((<Command>)).
      #
      # This is also aliased as <<
      def add(cmd)
        raise TypeError, 'Command::Block#add: Attempt to add non-Command object' unless cmd.kind_of?(Base)
        @commands << cmd
        self
      end
      def <<(cmd)
        add(cmd)
      end

      # Calls Command#output(context) on each Command contained in this 
      # object.  The output is returned as a single string.  If no output
      # is generated, returns an empty string.
      def output(context = nil)
        @commands.map {|cmd| cmd.output(context) }.join('')
      end
      
      # Returns Commands held, as a string
      def to_s
        '[ Blocks: ' + @commands.map {|cmd| "[#{cmd.to_s}]" }.join(' ') + ' ]'
      end
    end
  end
end