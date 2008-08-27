module Papyrus
  module Commands
    # An If command represents an 'if' statement.
    #
    # *Syntax*: [if <i>variable_or_literal</i>]...[/if],
    #           [unless <i>variable_or_literal</i>]...[/unless]<br />
    # *Modifiers*: [elsif <i>variable_or_literal</i>], [else]
    #
    # In the 'if' form, if _variable_ comes out to be true, the output of the whole
    # command will be the output of the block directly following the 'if' statement,
    # otherwise it's the output of a matching 'elsif' or 'else' block (if present).
    #
    # In the 'unless' form, if _variable_ comes out to be *false*, the output of the
    # whole command will be the output of the 'unless' block, otherwise the output
    # of the 'else' block (if present). Note that you cannot put an 'elsif' statement
    # following an 'unless' statement.
    #
    # === Examples
    #
    #  [if foo]
    #    This will be printed if [foo] is true
    #  [/if]
    #
    #  [unless bar]
    #    This will be printed if [bar] is true
    #  [/unless]
    #
    #  [if some_variable]
    #    This will be printed if [some_variable] is true
    #  [elsif some_other_variable]
    #    This will be printed if [some_other_variable] is true
    #  [else]
    #    This will be printed if neither is true
    #  [/if]
    #
    #  [unless quux]
    #    This will be printed if [quux] is false
    #  [else]
    #    This will be printed if [quux] is true
    #  [/unless]
    class If < BlockCommand
      aka :unless
      
      # An array of value-to-NodeList mappings used to store 'if' and 'elsif' blocks
      # if the command was called as 'if', or the 'else' block if the command was
      # called as 'unless'.
      attr_reader :true_commands
      # A NodeList used to store the 'else' block if the command was called as 'if',
      # or the 'unless' block if the command was called as 'unless'.
      attr_reader :false_commands
      # A boolean that will be true if we're in an 'unless' block, or if the command
      # was called as 'if' and we're in an 'else' block.
      attr_reader :in_else
      # A boolean that will be true if we're in an 'else' block, false otherwise.
      # Another way to say this is whether commands are being added to @true_commands
      # or @false_commands.
      attr_reader :switched
      
      # Creates a new If command, storing the initial variable or value passed
      # to the command.
      def initialize(*args)
        super
        @value = @args.first
        @true_commands = [ [@value, NodeList.new(self)] ]
        @false_commands = NodeList.new(self)
        @in_else = (@name == 'unless')
        @switched = false
      end
      
      def active_block
        in_else ? false_commands : true_commands.last.last
      end
      
      # Adds the given value to the list of @true_commands.
      #
      # An ArgumentError will be raised if @switched or @in_else is true, which
      # will be the case if you try to put an 'elsif' command following an 'else'
      # or 'unless' command.
      modifier(:elsif) do |args|
        raise ArgumentError, "'elsif' cannot be passed after 'else' or in an 'unless'" if @switched || @in_else
        value = args.first
        @true_commands << [ value, NodeList.new(self) ]
        true
      end
      
      # Switches the list to which new commands will be added (@true_commands or
      # @false_commands).
      #
      # An ArgumentError will be raised if @switched is set to true, which will be
      # the case if you try to put an 'else' command following an already existing
      # 'else' command.
      modifier(:else) do |args|
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = !@in_else
        @switched = true
        true
      end
      
      # Returns the output for the first block in @true_commands for which its
      # associated value evaluates to true within the given context.
      # If none of the values in @true_commands are true then the output of
      # @false_commands is returned.
      def output
        @true_commands.each do |value, block|
          return block.output if parent.true?(value)
        end
        @false_commands.output
      end
      
      def to_s
        str = '['
        if @name == 'if'
          label = 'If'
          @true_commands.each do |value, block|
            str << " #{label} (#{value}) #{block}"
            label = 'Elsif'
          end
          str << " Else: #{@false_commands}" unless @false_commands.empty?
        else
          str << " Unless (#{@value}): #{@false_commands}"
          str << " Else: #{@true_commands.first.last.to_s}" unless @true_commands.empty?
        end
        str << ' ]'
        str
      end
      
    end 
  end
end