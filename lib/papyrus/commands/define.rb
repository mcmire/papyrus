module Papyrus
  module Commands
    # A Define command will set a variable within the enclosing context
    class Define < Command
      def initialize(*args)
        super
        @var_name, @var_value = @args
      end

      # Doesn't return any output
      def output
        parent[@var_name] = @var_value
        return ""
      end
    end
  end
end