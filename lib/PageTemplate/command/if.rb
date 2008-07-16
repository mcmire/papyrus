class PageTemplate
  module Command
    # An If command is a Stackable command. It requires an opening:
    # [% if variable %] or [% unless variable %].
    #
    # On execution, if +variable+ is true, then the contents of
    # If's @commands is printed. 
    #
    # [% else %] may be specified for either if or unless, after which
    # objects are added to @false_commands, and are printed if +variable+
    # is false, instead.
    class If < Stackable
      @modifier = :elsif
      @closer   = :end

      # +command+ must match "if <value>" or "unless <value>"
      def initialize(called_as, value)
        @value = value
        @called_as = called_as
        @true_commands = []
        @true_commands << [value,Block.new]
        @false_commands = Block.new
        @in_else = (called_as == 'unless')
        @switched = false
      end
      # Add the command to the @true_commands or @false_commands block,
      # depending on if the command is an 'if' or 'unless' and if 'else'
      # has been called.
      def add(command)
        unless @in_else
          @true_commands.last.last.add command
        else
          @false_commands.add command
        end
      end
      # an elsif will create a new condition.
      def elsif(value)
        raise Argumentrror, "'elsif' cannot be passed after 'else' or in an 'unless'" if @switched || @in_else
        @true_commands << [value,Block.new]
      end
      # an 'else' will modify the command, switching it from adding to
      # @true_commands to adding to @false_commands, or vice versa.
      def else
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = ! @in_else
        @switched = true
      end
      # If @value is true within the context of +context+, then print
      # the output of @true_commands. Otherwise, print the output of
      # @false_commands
      def output(context=nil)
        val = ''
        @true_commands.each do |val,commands|
          return commands.output(context) if context.true?(val)
        end
        @false_commands.output(context)
      end
      def to_s
        str = '['
        if @called_as == 'if'
          str = ' If'
          label = ' If'
          str += @true_commands.map { |val,commands|
            s = "#{label} (#{val}) #{commands}"
            label = ' Elsif'
          }.join('')
          if @false_commands.length > 0
            str << " else: #{@false_commands}"
          end
        else
          str = "[ Unless (#{@value}): #{@false_commands}"
          if @true_commands.length > 0
            str << " else: #{@true_commands}"
          end
        end
        str << ' ]'
        str
      end
    end 
  end
end