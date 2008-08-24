module Papyrus
  module Commands
    # A Case command provides switch-command functionality.
    # [% case variable %]
    # [% when literal1 %]
    # [% when literal2 %]
    # [% when literal3 %]
    # [% else %]
    # [% end %]
    class Case < BlockCommand
      attr_reader :current_case
      
      # +value+ should be a literal value or a variable that will be evaluated into a
      # literal value within the context on execution. The literal value will be
      # tested against the literals supplied for each 'when' command following
      # (or an optional 'else' command).
      def initialize(*args)
        super
        @value = @args.first
        @blocks = {}
        @current_case = nil
        @default = NodeList.new(self)
      end
      
      # Adds a command to the current case, or to the 'else' (default) case.
      def add(cmd)
        (@current_case ? @blocks[@current_case] : @default) << cmd
        self
      end
      
      modifier(:when) do |args|
        value = args.first
        @current_case = value
        @blocks[value] = NodeList.new(self) unless @blocks.has_key?(value)
        true
      end
      
      modifier(:else) do |args|
        @current_case = nil
        true
      end
      
      # If context.get(@value) exists in the 'when' clauses, then
      # print out that block.
      def output
        val = parent.get(@value)
        if @blocks.has_key?(val)
          @blocks[val].output
        else
          @default.output
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