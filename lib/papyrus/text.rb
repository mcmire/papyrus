module Papyrus
  # Text is a very simple Node which outputs a static string of text
  class Text < Node
    # Creates a Text object, saving +text+ for future output.
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