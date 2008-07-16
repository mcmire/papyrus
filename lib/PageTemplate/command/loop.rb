class PageTemplate
  module Command
    # A Loop command is a Stackable command. It requires an opening:
    # [% if variable %] or [% unless variable %].
    #
    # +variable+ is fetched from the context.
    #
    # On execution, if +variable+ is true, and non-empty, then
    # @commands is printed once with each item in the list placed in
    # its own context and passed to the loop commands.
    # (a list is defined as an object that responds to :map)
    #
    # If +variable+ is true, but does not respond to :map, then
    # the list is called once
    #
    # [% else %] may be specified, modifying Loop to print out
    # @else_command in case +variable+ is false, or empty.
    class Loop < Stackable
      @modifier = :else
      @closer   = :end

      # [% in variable %] or [% loop variable %]
      # Or [% in variable: name %]
      def initialize(called_as, value, iterators)
        @called_as = called_as
        @value     = value
        if iterators
          @iterators = iterators.strip.gsub(/\s+/, ' ').split
        else
          @iterators = nil
        end

        @switched  = false
        @commands  = Block.new
        @else_command = Block.new
        @in_else = false
      end
      # An 'else' defines a list of commands to call when the loop is
      # empty.
      def else
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = ! @in_else
        @switched = true
      end
      # adds to @commands for the loop, or @else_command if 'else' has
      # been passed.
      def add(command)
        unless @in_else
          @commands.add command
        else
          @else_command.add command
        end
      end
      # If +variable+ is true, and non-empty, then @commands is printed
      # once with each item in the list placed in its own context and
      # passed to the loop commands.  (a list is defined as an object
      # that responds to :map)
      #
      # If +variable+ is true, but does not respond to :map, then
      # the list is called once
      def output(context)

        vals = context.get(@value)
        ns = nil
        return @else_command.output(context) unless vals
        unless vals.respond_to?(:map) && vals.respond_to?(:length)
          vals = [vals]
        end

        return @else_command.output(context) if vals.empty?

        # Unfortunately, no "map_with_index"
        len = vals.length
        i = 1
        odd = true
        ns = Context.new(context)

        # Print the output of all the objects joined together.
        case
        when @iterators.nil? || @iterators.empty?
          vals.map { |item|
            ns.clear
            ns.object = item
            ns['__FIRST__'] = (i == 1) ? true : false
            ns['__LAST__'] = (i == len) ? true : false
            ns['__ODD__'] = odd
            ns['__INDEX__'] = i-1
            odd = ! odd
            i += 1
            @commands.output(ns)
          }.join('')
        when @iterators.size == 1
          iterator = @iterators[0]
          vals.map { |item|
            ns.clear_cache
            # We have an explicit iterator - don't set an object for it.
            # ns.object = item
            ns['__FIRST__'] = (i == 1) ? true : false
            ns['__LAST__'] = (i == len) ? true : false
            ns['__ODD__'] = odd
            ns['__INDEX__'] = i-1
            odd = ! odd
            ns[iterator] = item
            i += 1
            @commands.output(ns)
          }.join('')
        else
          vals.map { |list|
            ns.clear_cache
            ns['__FIRST__'] = (i == 1) ? true : false
            ns['__LAST__'] = (i == len) ? true : false
            ns['__ODD__'] = odd
            ns['__INDEX__'] = i-1
            @iterators.each_with_index do |iterator,index|
              ns[iterator] = list[index]
            end
            odd = ! odd
            i += 1
            @commands.output(ns)
          }.join('')
        end
      end

      def to_s
        str = "[ Loop: #{@value} " + @commands.to_s
        str << " Else: " + @else_command.to_s if @else_command.length > 0
        str << ' ]'
        str
      end
    end 
  end
end