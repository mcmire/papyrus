module Papyrus
  # Template holds the top-level list of nodes assembled during the parsing process.
  # It is what is returned on Parser#parse.
  #
  # A Template should only be created by the Parser, and never by anything else.
  class Template < NodeList
    
    # Template is a context object
    include ContextItem
    
    # Template must know about the parser so it can access its context.
    def initialize(parser)
      super()
      @parser = parser
      @parent = parser
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
      if object.nil?
        super(self)
      elsif object.is_a?(ContextItem)
        @parent = object  # I don't like this b/c it's destructive
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