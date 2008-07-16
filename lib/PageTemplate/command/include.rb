class PageTemplate
  module Command
    # An Include command allows the designer to include a template from
    # another source.
    #
    # [% include variable %] or [% include literal %]
    #
    # If +literal+ exists in parser.source, then it is called without
    # passing it to its context. If it does not exist, then it is
    # evaluated within the context of its context and then passed to
    # parser.source for fetching the body of the file/source.
    #
    # The body returned by the Source is then passed to Parser for
    # compilation.
    class Include < Base
      def initialize(value)
        @value = value
      end
      def to_s
        "[ Include: #{@value} ]"
      end
      # If @value exists in parser.source, then it is called without
      # passing it to its context. If it does not exist, then it is
      # evaluated within the context of its context and then passed to
      # parser.source for fetching the body of the file/source.
      #
      # The body returned by the Source is then passed to Parser for
      # compilation.
      def output(context)
        # We don't use parser.compile because we need to know when something
        # doesn't exist.
        parser = context.parser
        fn = @value
        body = parser.source.get(fn)
        unless body
          fn = context.get(@value)
          body = parser.source.get(fn) if fn
        end
        if body.is_a?(Base)
          body.output(context)
        elsif body
          cmds = parser.parse(body)
          parser.source.cache(fn,cmds)
          cmds.output(context)
        else
          "[ Template '#{fn}' not found ]"
        end
      end
    end 
  end
end