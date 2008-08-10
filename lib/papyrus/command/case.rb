module Papyrus
  module Command
    # A Case command provides switch-command functionality.
    # [% case variable %]
    # [% when literal1 %]
    # [% when literal2 %]
    # [% when literal3 %]
    # [% else %]
    # [% end %]
    class Case < Stackable
      self.modifier = :when
      self.closer   = :end

      attr_reader :current_case
      
      # +value+ should be a literal value or a variable that will be evaluated into a
      # literal value within the context on execution. The literal value will be
      # tested against the literals supplied for each 'when' command following
      # (or an optional 'else' command).
      def initialize(lexicon, called_as, value)
        super
        @value = value
        @blocks = {}
        @current_case = nil
        @default = Block.new
      end
      
      # Adds a command to the current case, or to the 'else' (default) case.
      def add(cmd)
        (@current_case ? @blocks[@current_case] : @default) << cmd
        self
      end
      
      # modifier
      def when(value)
        @current_case = value
        @blocks[value] = Block.new unless @blocks.has_key?(value)
        true
      end
      
      # modifier
      def else
        @current_case = nil
        true
      end
      
      # If context.get(@value) exists in the 'when' clauses, then
      # print out that block.
      def output(context)
        val = context.get(@value, false)
        if @blocks.has_key?(val)
          @blocks[val].output(context)
        else
          @default.output(context)
        end
      end
      
      def to_s
        str = "[ Case: "
        @blocks.each do |key,val|
          str << " #{key}: [#{val}]"
        end
        str << " else #{@default.to_s}"
        str << " ]"
      end
    end
  end
end