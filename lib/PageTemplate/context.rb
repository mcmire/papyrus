module PageTemplate
  class Context
    
    include ContextItem

    def initialize(parent=nil, object=nil)
      @parent = parent
      @object = object
      @values = Hash.new
    end

    # Create a new top-level Context with a Hash-like object
    def Context.construct_from(hash)
      context = Context.new
      hash.each {|k, v| context[k] = v }
      context
    end
  end
end