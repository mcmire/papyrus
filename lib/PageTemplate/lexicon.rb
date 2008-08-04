module PageTemplate
  # This is the lexicon of commands and the command regex that Parser
  # uses to compile a template into a tree of commands.
  #
  # command_regexp is the general format of a PageTemplate command.
  # Default: /\[%(.+?)%\]/m
  #
  # @lexicon is a hash table of regexp->Command objects. These
  # regexps should not contain PageTemplate command text. i.e:
  # /var \w+/i should be used instead of /[% var %]/
  class Lexicon
    class << self
      attr_writer :command_open
      # If a string is given, sets @command_open to the string, otherwise returns
      # the value of @command_open.
      def command_open(str=nil)
        if str
          @command_open = str
        else
          @command_open
        end
      end
      
      attr_writer :command_close
      # If a string is given, sets @command_close to the string, otherwise returns
      # the value of @command_close.
      def command_close(str=nil)
        if str
          @command_close = str
        else
          @command_close
        end
      end
      
      # Takes @command_open and @command_close and creates the regexp that matches
      # an entire command.
      def command_regexp
        raise "command_open not defined"  unless @command_open
        raise "command_close not defined" unless @command_close
        Regexp.new(Regexp.escape(@command_open) + "(.*)" + Regexp.escape(@command_close))
      end
      
      attr_writer :default
      # If a symbol is given, sets @default to the symbol. If not, returns the value
      # of @default. If @default is not set, returns :unknown.
      def default(sym=nil)
        if sym
          @default = sym.to_sym
        else
          @default ||= :unknown
        end
      end

      # Looks up the given raw command in the hash of commands by testing each regex
      # stored in the @lexicon against the raw command. If a regex matches then we'll
      # have some Command class name and a block. We first yield the block, passing
      # the captures from the match, then we take the return value of the block
      # (a subset of those captures) and pass them to a new instance of the Command,
      # using the class name we have.
      #
      # If no regex matches, the command is not in the lexicon, so we just return
      # an instance of the designated default command, passing the raw command.
      def lookup(raw_command)
        lexicon.each do |regexp, cmd|
          if match = regexp.match(raw_command)
            captures = cmd[:block].call(match)
            return cmd[:klass].new(*captures)
          end
        end
        return Command.const_get(default.to_s.camelize).new(raw_command)
      end
      
      # Looks up +modifier+ (a symbol designating the type of modification, e.g. :end)
      # in the +modifiers+ hash and (if found) calls the resulting block stored for
      # that modifier, passing the given command object being modified and the given
      # raw command.
      #
      # Should have been named <tt>command_is_modifier_of?</tt>
      #--
      # TODO: I would much rather prefer this be defined in the Command class
      def modifies?(modifier, modifiee, raw_command)
        modifiers[modifier.to_sym].call(modifiee, raw_command)
      end
    
      # Associates a regexp with a class in the Command module and a block, storing
      # the association in the @lexicon hash.
      #
      # When a command is looked up, the regexp used here will be tested against the
      # command, and if it matches, the block will be yielded, receiving the
      # MatchData object. To be useful, the block should return whichever captures
      # you want to be passed on to the Command instance.
      #
      # Note that the regexp should not include the name of the command or
      # start-of-line and end-of-line assertions (^ and $, respectively); these will
      # be added automatically.
      #
      # There are two options you can pass:
      # * +class_name+ - Lets you specify the name of the class in the Command module
      #    that will be used to create the Command. By default this is derived from
      #    the +command_name+.
      # * +also+ - Lets you specify aliases for the command. For instance, in the
      #   DefaultLexicon, +if+ is aliased as +unless+.
      def define(command_name, regexp, options = {}, &block)
        unless command_name.is_a?(String) or command_name.is_a?(Symbol)
          raise ArgumentError, 'First argument to define must be a symbol or string'
        end
        unless regexp.is_a?(Regexp)
          raise ArgumentError, 'Second argument to define must be a Regexp'
        end
        command_name = command_name
        aliases = [ options[:also] || [] ].flatten
        source = regexp.source
        source.gsub!(/^\^/, '')
        source.gsub!(/\$$/, '')
        class_name = options[:class_name] || command_name.to_s.camelize
        ([command_name] + aliases).each do |name|
          regexp = Regexp.new("^(#{Regexp.escape(name.to_s)}) #{source}$", Regexp::IGNORECASE)
          adv_define(regexp, class_name, &block)
        end
      end
      
      # A more advanced version of +define+. Here you have to set the class name
      # yourself, the regexp is unmodified, and there are no options to specify.
      #
      # When a command is looked up, the regexp used here will be tested against the
      # command, and if it matches, the block will be yielded, receiving the
      # MatchData object. To be useful, the block should return whichever captures
      # you want to be passed on to the Command instance.
      def adv_define(regexp, class_name, &block)
        raise ArgumentError, 'First argument to adv_define must be a Regexp' unless regexp.is_a?(Regexp)
        block ||= proc {|match| match.captures }
        klass = Command.const_get(class_name)
        lexicon[regexp] = { :klass => klass, :block => block }
      end

      # Associates a type of command modification (a symbol) with a block, storing the
      # association in the @modifiers hash. The block will be executed in a call to
      # #modifies? and passed a Command and the contents of another command, so to
      # be useful, it should return true or false depending on its decision whether
      # or not the latter command modifies the former. 
      #--
      # TODO: I would much rather prefer this be defined in the Command class
      def modifier(sym, &block)
        raise ArgumentError, 'First argument to modifier must be a String or Symbol' unless sym.is_a?(Symbol) or sym.is_a?(String)
        raise ArgumentError, 'Block expected' unless block
        modifiers[sym.to_sym] = block
      end

      # This lets you write e.g. [% foo %] to refer to a 'foo' variable instead of
      # having to say [% var foo %]
      def define_global_var(regexp)
        regexp = /^(#{Regexp.escape(regexp.to_s)}(?:\.\w+\??)*)(?:\s:(\w+))?$/ unless regexp.is_a?(Regexp)
        adv_define(regexp, 'Value')
      end
      
    private
      def lexicon
        @lexicon ||= {}
      end
      
      def modifiers
        @modifiers ||= Hash.new(lambda { false })
      end
    end
  end
end