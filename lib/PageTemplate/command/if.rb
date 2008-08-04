module PageTemplate
  module Command
    # An If command is a Stackable command. It requires an opening:
    # [% if +variable+ %] or [% unless +variable+ %].
    #
    # When the command is executed, if +variable+ is true, then the contents of
    # If's @commands are printed. 
    #
    # [% else %] may be specified for either if or unless, after which
    # objects are added to @false_commands, and are printed if +variable+
    # is false, instead.
    #
    # Either @true_commands or @false_commands is used to store the block following
    # each statement, but it depends on whether the command was called as 'if' or
    # 'unless'.
    #
    # If the command was called as 'if', then 'if' and 'elsif' blocks will be stored
    # in @true_commands with their corresponding values to be evaluated, and the
    # 'else' block will be stored in @false_commands. So this PageTemplate code:
    #
    #  [% if foo %]
    #    ...
    #  [% elsif bar %]
    #    ...
    #  [% else %]
    #    ...
    #  [% end %]
    #
    # is codified as follows:
    #
    #  @true_commands = [
    #    ['foo', PageTemplate::Block.new ],
    #    ['bar', PageTemplate::Block.new ]
    #  ]
    #  @false_commands = PageTemplate::Block.new
    #
    # The output of the whole command, as you would expect, will be the output of the
    # 'if' block if its value evaluates to true, otherwise the output of the 'elsif'
    # block if its value evaluates to true, otherwise the output of the 'else' block.
    #
    # If the command was called as 'unless', then the 'unless' block will be stored
    # in @false_commands, and the 'else' @true_commands is used to store
    # just the 'else' statement, and the value stored with the block is the 'unless'
    # value. So this PageTemplate code:
    #
    #  [% unless foo %]
    #    ...
    #  [% else %]
    #    ...
    #  [% end %]
    #
    # would be stored as follows:
    #
    #  @true_commands = [
    #    [ 'foo', PageTemplate::Block.new ]
    #  ]
    #  @false_commands = PageTemplate::Block.new
    #
    # In this case, the output of the whole command will be the output of the 'else'
    # block if foo evaluates to true, otherwise it's the output of the 'unless'
    # block. Note that if there's no 'else' block given, then the output will be
    # the output of an empty block (since that's what @true_commands is set to initially).
    class If < Stackable
      self.modifier = :elsif
      self.closer   = :end

      # Creates a new If command, storing what the command was called_as
      # ("if" or "unless"), and the value that will get evaluated when the
      # command is executed.
      def initialize(called_as, value)
        super
        @value = value
        @true_commands = [ [value, Block.new] ]
        @false_commands = Block.new
        @in_else = (called_as == 'unless')
        @switched = false
      end
      
      # Adds the given command to @true_commands or @false_commands,
      # depending on if the command is an 'if' or 'unless' and if 'else'
      # has been called. (See the documentation for the If class for more.)
      def add(cmd)
        if @in_else
          @false_commands << cmd
        else
          @true_commands.last.last << cmd
        end
        self
      end
      
      # Adds the given value to the list of @true_commands.
      #
      # An ArgumentError will be thrown if @switched or @in_else is set to true,
      # which will be the case if you try to put an 'elsif' command following an
      # 'else' or 'unless' command.
      def elsif(value)
        raise ArgumentError, "'elsif' cannot be passed after 'else' or in an 'unless'" if @switched || @in_else
        @true_commands << [ value, Block.new ]
      end
      
      # Switches the list to which new commands will be added (@true_commands or
      # @false_commands).
      #
      # An ArgumentError will be thrown if @switched is set to true, which will be
      # the case if you try to put an 'else' command following an already existing
      # 'else' command.
      def else
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = !@in_else
        @switched = true
      end
      
      # Returns the output for the first block in @true_commands for which its
      # associated value evaluates to true within the given context.
      # If none of the values in @true_commands are true then the output of
      # @false_commands is returned.
      def output(context)
        @true_commands.each do |value, block|
          return block.output(context) if context.true?(value)
        end
        @false_commands.output(context)
      end
      
      def to_s
        str = '['
        if @called_as == 'if'
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