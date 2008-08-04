module PageTemplate
  # A StringSource is created with a raw string, which is returned on any
  # call to 'get'.
  class StringSource < Source
    def initialize(options)
      if options.is_a?(String)
        @source = options
      else
        options.symbolize_keys!
        @options = options
        @source = options[:source]
      end
    end
    
    def get(name=nil)
      @source
    end
  end
end