module Papyrus
  module Commands
    # An Include command allows the designer to include a template from
    # another source.
    #
    #  [% include ... %]
    #
    # The argument to 'include' may be the name of a file, or a variable in a
    # context that evaluates to a filename. If the filename refers to an existing
    # file, the content of the file is retrieved and passed through the Parser
    # and compiled into a Template. Otherwise the 'include' tag is replaced with
    # an error message.
    class Include < Command
      def initialize(*args)
        super
        @value = @args.first
      end
      
      # Returns the output of this command.
      #
      # We first assume that @value is the name of an existing file in parser.source.
      # If @value is not a filename, then we assume it is a variable name in the given
      # context; if the variable is found then we evaluate it and assume the return
      # value is a filename.
      #
      # Once we have a filename we send it to Source#get. If we get text back, then
      # we pass the text through the Parser to compile it into a Template; if we
      # get a precompiled Template back then we don't have to do that.
      #
      # Once we have a Template we just output the interpretation of that Template.
      #
      # If Context#get or Source#get fails to give us anything, then the output of
      # this command will be an error message.
      def output
        fn, template = get_template_from_value(context)
        template ? template.output(context) : "[ Template '#{fn}' not found ]"
      end
      
      def to_s
        "[ Include: #{@value} ]"
      end
      
    private
      def get_template_from_value(context)
        fn, template = get_compiled_or_uncompiled_template(context)
        template = compile_template(context, fn, template) if template && !template.kind_of?(Command)
        [fn, template]
      end
    
      def get_compiled_or_uncompiled_template(context)
        parser = context.parser
        fn = @value
        template = parser.source.get(fn) || (fn = context.get(@value) && parser.source.get(fn))
        [fn, template]
      end
      
      def compile_template(context, fn, content)
        parser = context.parser
        template = parser.parse(content)
        parser.source.cache(fn, template)
        template
      end
    end 
  end
end