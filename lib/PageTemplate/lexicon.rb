class PageTemplate
  # This is the dictionary of commands and the sub_regex that Parser
  # uses to compile a template into a tree of commands.
  #
  # sub_regex is the general format of a PageTemplate command.
  # Default: /\[%(.+?)%\]/m
  #
  # @lexicon is a hash table of regexp->Command objects. These
  # regexps should not contain PageTemplate command text. i.e:
  # /var \w+/i should be used instead of /[% var %]/
  class Lexicon
    class << self
      attr_accessor :sub_regex
      attr_writer :default
      def default(&block)
        if block_given?
          @default = block
        else
          @default
        end
      end

      # Look up +command+ to see if it matches a command within the lookup
      # table, returning the instance of the command for it, or
      # an Unknown command if none match.
      def lookup(command)
        @lexicon.each do |key,val|
          if m = key.match(command)
            return val.call(m)
          end
        end

        return @default.call(command)
      end
      def modifies?(modifier,cmd,command)
        @modifiers[modifier].call(cmd,command)
      end
    
      # Define a regexp -> Command mapping.
      # +rx+ is inserted in the lookup table as a key for +command+
      def define(rx,&block)
        raise ArgumentError, 'First argument to define must be a Regexp' unless rx.is_a?(Regexp)
        raise ArgumentError, 'Block expected' unless block
        @lexicon ||= {}
        @lexicon[rx] = block
      end

      def modifier(sym,&block)
        raise ArgumentError, 'First argument to define must be a Symbol' unless sym.is_a?(Symbol)
        raise ArgumentError, 'Block expected' unless block
        @modifiers ||= Hash.new(lambda { false })
        @modifiers[sym] = block
      end

      # This is shorthand for define(+key+,Valuecommand), and also
      # allows +key+ to be a string, converting it to a regexp before
      # adding it to the dictionary.
      def define_global_var(rx)
        @lexicon ||= {}
        rx = /^(#{key.to_s}(?:\.\w+\??)*)(?:\s:(\w+))?$/ unless rx.is_a?(Regexp)
        @lexicon[rx] = lambda { |match|
          Command::Value.new(match[1],match[2])
        }
      end
    end
  end
end