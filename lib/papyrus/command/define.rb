module Papyrus
  module Command
    # A Define command will set a variable within the enclosing context
    class Define < Base
      def initialize(*args)
        super
        @var_name, @var_value = @args
      end

      # Doesn't return any output
      def output(context)
        context[@var_name] = @var_value
        return ""
      end
    end
  end
end