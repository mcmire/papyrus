class PageTemplate
  module Command
    # An Unknown command is exactly that: A command we know nothing
    # about.
    #
    # We keep this and save it for future use in case we will know
    # something about it before output is called.
    class Unknown < Base
      # If the command that the Unknown command is set to exists, find out if
      # the command exists in the Parser's lexicon.
      def output(context)
        cls = context.parser.lexicon.lookup(@command)
        case cls
        when Unknown
          "[ Unknown Command: #{@command} ]"
        else
          cls.output(context)
        end
      end
      # Save the +command+ and the +parser+, so we can look it
      # up and hopefully 
      def initialize(command)
        @command = command
      end
      def to_s
        "[ Command::Unknown: #{@command} ]"
      end
    end
  end
end