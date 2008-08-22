module Papyrus
  module Filters; end
  class << Filters
    # Default, unescaped string.
    def unescaped(string)
      string
    end
    # Reverse the string. Don't see any use for this :D.
    def reverse(string)
      string.reverse
    end
    # escape URIs into %20-style escapes.
    def escape_uri(string)
      string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.tr(' ', '+')
    end
    # Escape all HTML
    def escape_html(string)
      string = string.gsub(/&/n, '&amp;')
      string.gsub!(/\"/n, '&quot;')
      string.gsub!(/>/n, '&gt;')
      string.gsub!(/</n, '&lt;')
      string
    end
    # Escape HTML, but also turn newlines into <br />s
    def nl2br(str)
      escape_html(str).gsub(/\r\n|\n/, "<br />\n")
    end
  end
  
  class Filter
    class << self
      def filter(filter, text, &block)
        filter = :unescaped unless Filters.respond_to?(filter)
        Filters.send(filter, text)
      end
    end
  end
end