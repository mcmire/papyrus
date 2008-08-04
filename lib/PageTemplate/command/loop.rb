module PageTemplate
  module Command
    # A Loop command is a Stackable command. It requires an opening:
    # [% in variable %] or [% loop variable %].
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
    # @else_commands in case +variable+ is false, or empty.
    class Loop < Stackable
      self.modifier = :else
      self.closer   = :end

      # [% in variable %] or [% loop variable %]
      # Or [% in variable: name %]
      def initialize(called_as, value, block_params)
        super
        @value = value
        @block_params = block_params && block_params.strip.gsub(/\s+/, ' ').split
        @switched = false
        @commands = Block.new
        @else_commands = Block.new
        @in_else = false
      end
      
      # An 'else' defines a list of commands to call when the loop is
      # empty.
      def else
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = !@in_else
        @switched = true
      end
      
      # Adds the given command to @commands if we're inside a 'loop' block,
      # otherwise adds it to the @else_commands.
      def add(cmd)
        (@in_else ? @else_commands : @commands) << cmd
        self
      end
      
      # Returns the output of this command.
      #
      # First we evaluate the expression passed to 'loop' in the given context
      # and check that the value that comes out isn't nil or empty. If it is
      # nil or empty, then the 'else' block is executed, otherwise we start the
      # loop. We also check that the value we're going to be looping over is,
      # in fact, loopable -- i.e., that it's an Enumerable object (so an array,
      # hash, etc.); if not, we wrap it in an array.
      #
      # We then start looping through each item in the enumerable. For each
      # iteration, a new context is created. We use this context object to set
      # some local variables inside the block so users can access them.
      #
      # The first set of local variables we set concerns the item itself, and how we
      # do so depends on whether or not block parameters were supplied in the 'loop'
      # call, and how many.
      #
      # If there were block parameters supplied and the item is an array and this
      # array has more than one item, then the array is split out into the block
      # parameters. For instance, if two parameters were given, 'foo' and 'bar', and
      # the array == ['red', 'blue'], then 'foo' will be set to 'red' and 'bar' will
      # be set to 'blue'. If there are more parameters given than values in the array,
      # the unpairable parameters will be set to nil. If there are less, then the
      # unpairable values are ignored. (Try it.)
      #
      # Otherwise, we set context.object to the item. This means that if a user
      # accesses a variable inside the loop block PageTemplate will check to see
      # whether the "variable" is really a method on the item.
      #
      # Note that if the object we're enumerating over is a hash, then each item
      # will be a two-value array, storing the key and value.
      #
      # The second set of local variables we set only applies if the enumerable is an
      # array, and they're metavariables that the user can use to access info about
      # the loop:
      # 
      # * loop.index, the index of the item in the array (starts at 1, not 0)
      # * loop.is_first, a boolean that signifies whether or not the item is
      #   the first in the array
      # * loop.is_last, a boolean signifying whether or not the item is the last
      #   in the array
      # * loop.is_odd, a boolean signifying whether or not the index is an odd number
      #   (starts at 0)
      #
      # The very last thing we do is take the @commands in the 'loop' block itself
      # and execute them in the context we've set up, and add the content to a string
      # that we then return at the very end.
      def output(context)
        enum = context.get(@value)
        
        return @else_commands.output(context) if enum.blank?
        
        enum = [enum] unless enum.is_a?(Enumerable)
        enum.inject_with_index("") do |output, item, i|
          subcontext = create_subcontext(context, enum, item, i)
          output << @commands.output(subcontext)
        end
      end

      def to_s
        str = "[ Loop: #{@value} #{@commands}"
        str << " Else: #{@else_commands}" unless @else_commands.empty?
        str << " ]"
        str
      end
      
    private
      def create_subcontext(context, enum, item, i)
        subcxt = Context.new(context)
        set_block_params(subcxt, item)
        set_metavariables(subcxt, enum, i)
        subcxt
      end
      
      def set_block_params(subcxt, item)
        if @block_params.blank?
          # include this item while resolving variables accessed during the block
          subcxt.object = item
        elsif item.is_a?(Array) && item.size > 1
          # split item into block variables
          # @block_params may be < subitems, so put it first
          @block_params.zip(item).each {|param, subitem| subcxt[param] = subitem }
        else
          # now this item is available thru the block variable
          subcxt[@block_params.first] = item
        end
      end
      
      def set_metavariables(subcxt, enum, i)
        return unless enum.is_a?(Array)
        # set metavariables
        subcxt['iter'] = {
          'is_first' => (i == 0),
          'is_last'  => (i == enum.size-1),
          'is_odd'   => (i % 2 != 0),
          'index'    => i+1
        }
      end
    end 
  end
end