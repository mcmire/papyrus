module PageTemplate
  # A Source is a source from which templates are drawn.
  #
  # Source#get(name) must return the body of the template that is to
  # be parsed, or nil if it doesn't exist.
  class Source
    def initialize(options = {})
      @options = options
    end

    def get(name=nil)
      name
    end
  end
end