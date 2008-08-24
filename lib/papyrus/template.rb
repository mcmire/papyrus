module Papyrus
  # Template holds the top-level list of nodes assembled during the parsing process.
  # It is what is returned on Parser#parse.
  #
  # A Template should only be created by the Parser, and never by anything else.
  class Template < NodeList
    def initialize(parser)
      super()
      @parser = parser
    end
    
    def to_s
      '[ Template: ' + @nodes.map {|node| "[#{node.to_s}]" }.join(' ') + ' ]'
    end
  end
end