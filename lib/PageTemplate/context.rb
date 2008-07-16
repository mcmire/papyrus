class PageTemplate
  class Context
    include ContextItem

    def initialize(parent=nil,object=nil)
      @values = Hash.new
      @parent = parent
      @object = object
    end

    # Create a new top-level Context with a Hash-like object
    def Context.construct_from(arg)
      ns = Context.new()
      arg.each { |k, v|
        ns[k] = v
      }
      return ns
    end
  end
end