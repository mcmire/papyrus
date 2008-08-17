module Papyrus
  module Commands
    # An If command is a BlockCommand command. It requires an opening:
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
    # 'else' block will be stored in @false_commands. So this Papyrus code:
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
    #    ['foo', Papyrus::NodeList.new ],
    #    ['bar', Papyrus::NodeList.new ]
    #  ]
    #  @false_commands = Papyrus::NodeList.new
    #
    # The output of the whole command, as you would expect, will be the output of the
    # 'if' block if its value evaluates to true, otherwise the output of the 'elsif'
    # block if its value evaluates to true, otherwise the output of the 'else' block.
    #
    # If the command was called as 'unless', then the 'unless' block will be stored
    # in @false_commands, and the 'else' @true_commands is used to store
    # just the 'else' statement, and the value stored with the block is the 'unless'
    # value. So this Papyrus code:
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
    #    [ 'foo', Papyrus::NodeList.new ]
    #  ]
    #  @false_commands = Papyrus::NodeList.new
    #
    # In this case, the output of the whole command will be the output of the 'else'
    # block if foo evaluates to true, otherwise it's the output of the 'unless'
    # block. Note that if there's no 'else' block given, then the output will be
    # the output of an empty block (since that's what @true_commands is set to initially).
    class If < BlockCommand
      aka :unless
      
      # Creates a new If command, storing what the command was called as
      # ("if" or "unless"), and the value that will get evaluated when the
      # command is executed.
      def initialize(*args)
        super
        @value = @args.first
        @true_commands = [ [@value, NodeList.new] ]
        @false_commands = NodeList.new
        @in_else = (@name == 'unless')
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
      modifier(:elsif) do |args|
        raise ArgumentError, "'elsif' cannot be passed after 'else' or in an 'unless'" if @switched || @in_else
        value = args.first
        @true_commands << [ value, NodeList.new ]
        true
      end
      
      # Switches the list to which new commands will be added (@true_commands or
      # @false_commands).
      #
      # An ArgumentError will be thrown if @switched is set to true, which will be
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
      def output(context)
        @true_commands.each do |value, block|
          return block.output(context) if context.true?(value)
        end
        @false_commands.output(context)
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