module Papyrus
  # Parser uses a Template to hold the top-level list of nodes during the parsing process.
  # A Template should only be created by the Parser, and never by anything else.
  class Template < NodeList
    # Creates a new Template, storing the given Parser, and possibly the given
    # context variables.
    def initialize(parser, vars={})
      super()
      @parser = parser
      @vars = vars
    end
    
    def to_s
      '[ Template: ' + @nodes.map {|node| "[#{node.to_s}]" }.join(' ') + ' ]'
    end
  end
end