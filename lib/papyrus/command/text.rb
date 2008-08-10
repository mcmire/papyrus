module Papyrus
  module Command
    # Text is a very simple Command which outputs a static string of text
    class Text < Base
      # Creates a Command::Text object, saving +text+ for future output.
      def initialize(text)
        @text = text
      end

      # Returns the string provided during this object's creation.
      def output(context = nil)
        @text
      end
      
      def to_s
        @text
      end
    end
  end
end