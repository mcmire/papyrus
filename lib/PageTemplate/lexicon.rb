module PageTemplate
  # This is the lexicon of commands and the command regex that Parser
  # uses to compile a template into a tree of commands.
  #
  # command_regex is the general format of a PageTemplate command.
  # Default: /\[%(.+?)%\]/m
  #
  # @lexicon is a hash table of regexp->Command objects. These
  # regexps should not contain PageTemplate command text. i.e:
  # /var \w+/i should be used instead of /[% var %]/
  class Lexicon
    class << self
      attr_accessor :command_regex
      
      attr_writer :default
      def default(&block)
        if block_given?
          @default = block
        else
          @default
        end
      end

      # Looks up the given command in the hash of commands, returning the
      # instance of the command stored under that name if one is found, or the
      # default command.
      def lookup(raw_command)
        lexicon.each do |regexp, block|
          if m = regexp.match(raw_command) then return block.call(m) end
        end
        return @default.call(raw_command)
      end
      
      # Looks up +modifier+ (a symbol designating the type of modification, e.g. :end)
      # in the +modifiers+ hash and (if found) calls the resulting block stored
      # for that modifier, passing the given command object being modified and the given
      # raw command.
      #
      # Should have been named <tt>command_is_modifier_of?</tt>
      #
      # TODO: I would much rather prefer this be defined in the Command class
      def modifies?(modifier, modifiee, raw_command)
        modifiers[modifier.to_sym].call(modifiee, raw_command)
      end
    
      # Associates a regexp with a block, storing the association in the @lexicon hash.
      # When a command is looked up, the regex used here will be tested against the
      # command, and if it matches, the block will be executed. Hence, to be useful,
      # the block in the command definition should return a Command::Base instance,
      # passing the Command constructor the proper pieces of the contents of the command
      # (derived from the captures in the regexp).
      def define(regexp, &block)
        raise ArgumentError, 'First argument to define must be a Regexp' unless regexp.is_a?(Regexp)
        raise ArgumentError, 'Block expected' unless block
        lexicon[regexp] = block
      end

      # Associates a type of command modification (a symbol) with a block, storing the
      # association in the @modifiers hash. The block will be executed in a call to
      # #modifies? and passed a Command and the contents of another command, so to
      # be useful, it should return true or false depending on its decision whether
      # or not the latter command modifies the former. 
      #
      # TODO: I would much rather prefer this be defined in the Command class
      def modifier(sym, &block)
        raise ArgumentError, 'First argument to define must be a String or Symbol' unless sym.is_a?(Symbol) or sym.is_a?(String)
        raise ArgumentError, 'Block expected' unless block
        modifiers[sym.to_sym] = block
      end

      # This is kind of a shorthand for <tt>define(+key+, +Value command+)</tt>.
      # +key+ is converted to a certain regexp before it's added to the lexicon.
      def define_global_var(rx)
        rx = /^(#{rx.to_s}(?:\.\w+\??)*)(?:\s:(\w+))?$/ unless rx.is_a?(Regexp)
        lexicon[rx] = lambda { |match|
          Command::Value.new(match[1],match[2])
        }
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