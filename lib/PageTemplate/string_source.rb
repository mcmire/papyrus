class PageTemplate
  # A StringSource is created with a raw string, which is returned on any
  # call to 'get'.
  class StringSource < Source
    def initialize(args)
      if args.class == String
        @source = args
      else
        @args = args
        @source = args["source"]
      end
    end
    def get()
      return @source
    end
  end
end