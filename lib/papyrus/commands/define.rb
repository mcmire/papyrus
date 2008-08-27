module Papyrus
  module Commands
    # A Define command sets a variable within the surrounding context. It doesn't
    # return any output.
    #
    # *Syntax*: [define _name_ _value_]
    #
    # === Example ===
    #
    #  [define michael "jordan"]
    class Define < Command
      # Creates a new Define object, storing the given variable name and value.
      def initialize(*args)
        super
        @var_name, @var_value = @args
      end

      # Stores the variable in the parent context, returning an empty string.
      def output
        parent.set(@var_name, @var_value)
        return ""
      end
    end
  end
end