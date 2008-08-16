module Papyrus
  # Template is the top-level Block object.
  # It is what is returned on Parser#load or Parser#parse.
  #
  # A Template should only be created by the Parser, and never by anything else.
  #---
  # Should this be a NodeList instead of a BlockCommand?
  class Template < BlockCommand
    
    # Template is a context object
    include ContextItem
    
    @modifier = nil
    @closer   = nil
    
    # Template must know about the parser so it can access its context.
    def initialize(parser)
      @parser = parser
      @parent = self
      super()
    end
    
    # Template#output is a special case for a Command. Because
    # Template is what's returned by Parser#load or Parser#parse,
    # the programmer may well call Template#output(anything).
    #
    # If +object+ is a Context, then treat output as a typical
    # Block command. If +object+ is nil, then context is
    # @parser. Otherwise, a new context is created, a
    # child of @context, and is assigned +object+ as its context.
    def output(object=nil)
      @parent = @parser
      if object.nil?
        super(self)
      elsif object.is_a?(ContextItem)
        @parent = object
        super(self)
      else
        context = Context.new(self)
        context.object = object
        super(context)
      end
    end
    
    def to_s
      '[ Template: ' + @nodes.map {|node| "[#{node.to_s}]" }.join(' ') + ' ]'
    end
  end
end