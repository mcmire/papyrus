class PageTemplate
  # Template is the top-level Block object.
  # It is what is returned on Parser#load or Parser#parse.
  #
  # Template should only be called by the Parser, and never
  # by anything else.
  class Template < Command::Block
    @modifier = nil
    @closer   = nil
    # Template must know about the parser so it can access its
    # context.
    def initialize(parser)
      @parser = parser
      super()
    end
    def to_s
      '[ Template: ' + @command_block.map{ |i| "[#{i.to_s}]" }.join(' ') + ']'
    end

    # Template is also a ContextItem
    include ContextItem

    # Template#output is a special case for a Command. Because
    # Template is what's returned by Parser.load() or Parser.parse(),
    # the programmer may well call Template#output(anything).
    #
    # If +object+ is a Context, then treat output as a typical
    # Block command. If +object+ is nil, then context is
    # @parser. Otherwise, a new context is created, a
    # child of @context, and is assigned +object+ as its context
    def output(object=nil)
      @parent = @parser
      case
      when object.nil?
        super(self)
      when object.is_a?(ContextItem)
        @parent = object
        super(self)
      else
        context = Context.new(self)
        context.object = object
        super(context)
      end
    end
  end
end