module Papyrus
  module Command
    # An Unknown command is a command that could not be found in the parser's lexicon.
    # We keep the raw version of the command that was called and save it for future
    # use in case it becomes a real command before it is output.
    class Unknown < Base
      # Creates a new Unknown command, storing the raw command that could not be
      # found so that we can look it up later.
      def initialize(lexicon, raw_command)
        @lexicon = lexicon
        @raw_command = raw_command
      end
      
      # Looks up the unknown command in the parser's lexicon. If the command in fact
      # exists, then returns the output of the command, otherwise returns an error string.
      def output(context)
        cmd = lexicon.lookup(@raw_command)
        if cmd.is_a?(Unknown)
          "[ Unknown Command: #{@raw_command} ]"
        else
          cmd.output(context)
        end
      end
      
      def to_s
        "[ Command::Unknown: #{@raw_command} ]"
      end
    end
  end
end