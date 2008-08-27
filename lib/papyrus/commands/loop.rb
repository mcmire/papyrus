module Papyrus
  module Commands
    # A Loop command gives you the ability to loop through an Enumerable and do
    # something for each iteration.
    #
    # *Syntax:* [loop <i>variable_or_literal</i> (<i>block_param1 block_param2 ...</i>)]<br />
    # *Modifiers:* [else]
    #
    # When the command is evaluated, _variable_ is fetched from the surrounding
    # context. The result must be some sort of Enumerable, but not a String. 
    # The block is then executed for each item in the Enumerable. The block is given
    # its own context.
    #
    # Inside of the block you are given access to the item that's currently selected
    # in some way. How this happens depends on whether you supply block parameters
    # after the variable name.
    #
    # * If you do not supply any block parameters, then any subs within the block are
    #   first treated as method calls on the item.
    # * If you supply one block parameter, the parameter is set to the item.
    # * If you supply more than block parameter, the item (assuming it's an Array)
    #   is split out into each of the block parameters.
    #
    # === Examples
    #
    #  <ul>
    #  [loop posts]
    #    <li>Post title: [title]</li>
    #    <li>Post body: [body]</li>
    #  [/loop]
    #  </ul>
    #
    #  <ul>
    #  [loop hash k v]
    #    <li><b>[k]</b>: [v]</li>
    #  [/loop]
    #  </ul>
    class Loop < BlockCommand
      attr_reader :value, :block_params
      attr_reader :commands, :else_commands
      attr_reader :in_else
      
      # Creates a new Loop command, storing the given Enumerable and possibly
      # block parameters.
      def initialize(*args)
        super
        @value, @block_params = @args
        @block_params = @block_params.strip.gsub(/\s+/, ' ').split if @block_params
        @switched = false
        @commands = NodeList.new(self)
        @else_commands = NodeList.new(self)
        @in_else = false
      end
      
      # Returns @else_commands if we're in the 'else' block, otherwise @commands.
      def active_block
        in_else ? else_commands : commands
      end
      
      modifier(:else) do |args|
        raise ArgumentError, "More than one 'else' to Command::If" if @switched
        @in_else = !@in_else
        @switched = true
        true
      end
      
      # Returns the output of this command.
      #
      # First we evaluate the variable passed to 'loop' in the given context.
      # If it is nil or empty, we execute the 'else' block immediately and return
      # the result. Otherwise, we check that the value we're going to be
      # looping over is, in fact, loopable -- i.e., that it's an Enumerable object
      # (so an array, hash, etc.), but not a String -- wrapping the value in an array
      # if it's not in the right form.
      #
      # We then start looping through each item in the enumerable. Each iteration
      # by design gets its own context. We use this context to set some local
      # variables inside the block so users can access them. First, we provide some
      # sort of access to the current item within the block, and this depends on
      # whether or not block parameters were supplied in the 'loop' call, and how
      # many. Next we provide access to information about the iteration itself, such
      # as the index and whether or not we're on the first or last item. Please
      # consult #set_block_params and #set_metavariables for more.
      #
      # The output is, naturally, the output of the block for as many items as are in the
      # enumerable.
      def output
        enum = parent.get(@value)
        
        return else_commands.output if enum.blank?
        
        enum = [enum] if enum.is_a?(String) || !enum.is_a?(Enumerable)
        enum.inject_with_index("") do |output, item, i|
          set_block_params(item)
          set_metavariables(enum, i)
          str = commands.output
          output << str
        end
      end

      def to_s
        str = "[ Loop: #{value} #{commands}"
        str << " Else: #{else_commands}" unless else_commands.empty?
        str << " ]"
        str
      end
      
    private
      # If there were block parameters supplied and the item is a multiple-element
      # array, the item is split out into the block parameters. For instance,
      # if two parameters were given, 'foo' and 'bar', and the item is
      # <tt>['red', 'blue']</tt>, then <tt>[foo]</tt> will evaluate to 'red' and 
      # <tt>[bar]</tt> will evaluated to 'blue'. If there are more parameters given
      # than the number of elements in the item, the unpairable parameters will be
      # set to nil. If there are less, then the unpairable values are ignored.
      #
      # If no block parameters were given, then any time a user accesses a variable
      # inside the loop block Papyrus will check to see whether the "variable" is
      # really a method on the item.
      #
      # Note that if the object we're iterating over is a hash, then each item
      # will be a two-value array, the key and value, and in that case if you wanted
      # to access both you'd have to supply two block parameters.
      def set_block_params(item)
        if block_params.blank?
          commands.object = item
        elsif item.is_a?(Array) && item.size > 1
          # split item into block variables
          # the # of @block_params may be < the # of subitems, so put it first
          block_params.zip(item).each {|param, subitem| commands.set(param, subitem) }
        else
          # now this item is available thru the block variable
          commands.set(block_params.first, item)
        end
      end
      
      # These metavariables will be set inside the current block if enumerable is an
      # Array:
      # 
      # * <tt>iter.index</tt>, the index of the item in the array (starts at 1, not 0)
      # * <tt>iter.is_first</tt>, a boolean that signifies whether or not the item is
      #   the first in the array
      # * <tt>iter.is_last</tt>, a boolean signifying whether or not the item is the
      #   last in the array
      # * <tt>iter.is_odd</tt>, a boolean signifying whether or not the index is an
      #   odd number (starts at 0)
      def set_metavariables(enum, i)
        return unless enum.is_a?(Array)
        commands.set('iter',
          'is_first' => (i == 0),
          'is_last'  => (i == enum.size-1),
          'is_odd'   => ((i+1) % 2 != 0),
          'index'    => i+1
        )
      end
    end 
  end
end