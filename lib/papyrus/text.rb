module Papyrus
  # Text is a very simple Node which outputs a static string of text.
  class Text < Node
    attr_reader :text
    
    # Creates a new Text node, storing the given text.
    def initialize(text)
      @text = text
    end

    # Just returns the text given to Text.new.
    def output
      @text
    end
    
    def to_s
      @text
    end
    
    # for testing
    def ==(other)
      other.is_a?(self.class) ? @text == other.text : super
    end
  end
end