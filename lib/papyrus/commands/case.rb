module Papyrus
  module Commands
    # A Case command provides switch-case functionality.
    #
    # *Syntax:* [case <i>variable_or_value</i>]...[/case]<br />
    # *Modifiers:* [when <i>literal</i>], [else]
    #
    # === Example
    #
    #  [case first_name]
    #  [when "Joe"] Buck
    #  [when "Michael"] Jordan
    #  [when "Shia"] LeBeouf
    #  [else] Smith
    #  [/case]
    class Case < BlockCommand
      attr_reader :current_case
      
      # Creates a new Case command, storing the given variable or value that each
      # case will be compared to.
      def initialize(*args)
        super
        @value = @args.first
        @blocks = {}
        @current_case = nil
        @default = NodeList.new(self)
      end
      
      # Since BlockCommands have the ability to contain multiple blocks, returns
      # the block that we're currently inside ('when' or 'else').
      def active_block
        current_case ? blocks[current_case] : default
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
      
      # Looks up the stored value in the parent context, and uses the resulting value
      # to find a 'when' block by key, or uses the 'else' block if one is not found,
      # and returns the output of that block. 
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
      
    private
      attr_reader :blocks, :default
    end
  end
end