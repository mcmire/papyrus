module Papyrus
  # A Token is used in the parsing process to better distinguish special characters
  # in the template being parsed and thus make it possible to interpret the template
  # procedurally.
  module Token
    class Base < ::String
      def to_s
        String.new(self)
      end
    end
    class DoubleQuote < Base
      def initialize(str='"')
        super(str)
      end
    end
    class SingleQuote < Base
      def initialize(str="'")
        super(str)
      end
    end
    class LeftBracket < Base
      def initialize(str="[")
        super(str)
      end
    end
    class RightBracket < Base
      def initialize(str="]")
        super(str)
      end
    end
    class Slash < Base
      def initialize(str="/")
        super(str)
      end
    end
    class Whitespace < Base
      def initialize(str=" ")
        super(str)
      end
    end
    class Text < Base; end
  
    # Returns a new Token based on the given text.
    def self.create(text)
      klass = case text
        when '"'    then DoubleQuote
        when "'"    then SingleQuote
        when "["    then LeftBracket
        when "]"    then RightBracket
        when "/"    then Slash
        when /^\s$/ then Whitespace
        else             Text
      end
      klass.new(text)
    end
  end
end