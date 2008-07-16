class PageTemplate
  class DefaultPreprocessor
    class << self
      # Default, unescaped string.
      def unescaped(str)
        str
      end
      # :process, for backwards compatability.
      alias_method :process, :unescaped
      # Reverse the string. Don't see any use for this :D.
      def reverse(str)
        str.reverse
      end
      # escape URIs into %20-style escapes.
      def escapeURI(string)
        string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
        '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end.tr(' ', '+')
      end
      # Escape all HTML
      def escapeHTML(string)
        str = string.gsub(/&/n, '&amp;')
        str.gsub!(/\"/n, '&quot;')
        str.gsub!(/>/n, '&gt;')
        str.gsub!(/</n, '&lt;')
        str
      end
      # Escape HTML, but also turn newlines into <br />s
      def simple(str)
        escapeHTML(str).gsub(/\r\n|\n/,"<br />\n")
      end
    end
  end
end