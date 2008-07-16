class PageTemplate
  module Command
    # A Define command will set a variable within the enclosing context
    class Define < Base
      def initialize(name, value)
        @name = name
        @value = value
      end

      # Doesn't return any output
      def output(context)
        context[@name] = @value
        return
      end
    end
  end
end