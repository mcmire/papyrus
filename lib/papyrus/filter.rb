module Papyrus
  module Filters; end
  class << Filters
    # Just returns the string
    def unescaped(string)
      string
    end
    # Reverses the string
    def reverse(string)
      string.reverse
    end
    # Escapes URIs into %20-style escapes
    def escape_uri(string)
      string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
      end.tr(' ', '+')
    end
    # Escapes all HTML
    def escape_html(string)
      string = string.gsub(/&/n, '&amp;')
      string.gsub!(/\"/n, '&quot;')
      string.gsub!(/>/n, '&gt;')
      string.gsub!(/</n, '&lt;')
      string
    end
    # Escapes HTML, but also turn newlines into <br />s
    def nl2br(str)
      escape_html(str).gsub(/\r\n|\n/, "<br />\n")
    end
  end
  
  class Filter
    class << self
      # Runs the text through the given filter and returns the result, or returns the
      # original text if +filter+ is not a filter.
      def filter(filter, text)
        Filters.respond_to?(filter) ? Filters.send(filter, text) : text
      end
    end
  end
end