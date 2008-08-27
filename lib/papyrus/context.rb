module Papyrus
  # A Context is a simple ContextItem
  class Context
    
    include ContextItem

    # Creates a new Context, storing the optional parent and object, which
    # may be used later when accessing context variables.
    def initialize(parent=nil, object=nil)
      @parent = parent
      @object = object
      @vars = Hash.new
    end

    # Create a new Context, merging the given hash with the context's variables.
    def Context.construct_from(hash)
      context = Context.new
      context.vars = hash
      context
    end
  end
end