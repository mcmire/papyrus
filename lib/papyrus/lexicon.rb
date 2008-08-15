module Papyrus
  # A base class used to define the lexicon of commands that you want to be used
  # in your templates.
  #
  # In *your* lexicon, at a minimum, you should define the token that opens a command,
  # the token that closes a command, and the commands themselves. Read the
  # documentation on +bra+, +ket+, +define+ and +adv_define+ for more.
  #---
  # TODO: Update docs
  class Lexicon
    class CommandNotFoundError < StandardError; end
    
    class << self
      
      def commands
        @commands ||= {}
      end
      
      def modifiers
        @modifiers ||= {}
      end

      # Looks up the given raw command in the hash of commands by testing each regex
      # stored in the @commands against the raw command. If a regex matches then we'll
      # have some Command class name and a block. We first yield the block, passing
      # the captures from the match, then we take the return value of the block
      # (a subset of those captures) and pass them to a new instance of the Command,
      # using the class name we have.
      #
      # If no regex matches, the command is not in the lexicon, so we just return
      # an instance of the designated default command, passing the raw command.
      #---
      # TODO: Update tests, docs
      def lookup(command_name, args)
        raise CommandNotFoundError unless commands.include?(command_name)
        begin
          klass = Command.const_get(command_name.camelize)
          klass.new(self, command_name, args)
        rescue NameError
          raise CommandNotFoundError
        end
      end
      
      # Checks to see whether the given command object is a Stackable and if
      # +raw_command+ is a valid modifier of the given command, or is contained in the
      # global hash of modifiers. If so, returns the name of the modifier (a symbol)
      # and a MatchData object, otherwise nil.
      def modifier_on(raw_command, modifiee)
        return unless modifiee.is_a?(Command::Stackable)
        if cmd = commands[modifiee.class]
          cmd[:modifiers].each do |modifier, regexp|
            if match = regexp.match(raw_command)
              return [modifier, match]
            end
          end
        end
        modifiers.each do |modifier, block|
          regexp = block.call(modifiee)
          if match = regexp.match(raw_command)
            return [modifier, match]
          end
        end
        nil
      end
      
      # Checks to see whether the given command object is a Stackable and if
      # +raw_command+ is contained in the global hash of closers. If so, returns the
      # name of the closer (a symbol) and a MatchData object, otherwise nil.
      #---
      # TODO: Don't need this anymore?
      def closer_on(raw_command, modifiee)
        if modifiee.is_a?(Command::Stackable) and \
        closer = self.closer and regexp = closer[:block].call(modifiee) and match = regexp.match(raw_command)
          [ closer[:name], match ]
        end
      end
    
      # Associates a regexp with a class in the Command module and a block, storing
      # the association in the @commands hash.
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
      # There are three options you can pass:
      # * +modifiers+ - Lets you specify other commands that modify this command
      #   when called inside it (only effective if this command is a Block or Stackable)
      # * +class_name+ - Lets you specify the name of the class in the Command module
      #    that will be used to create the Command. By default this is derived from
      #    the +command_name+.
      # * +also+ - Lets you specify aliases for the command. For instance, in the
      #   DefaultLexicon, +if+ is aliased as +unless+.
      #---
      # TODO: Simplify?
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
        modifiers = options[:modifiers] || {}
        command_names = ([command_name] + aliases).map {|name| Regexp.escape(name.to_s) }.join("|")
        regexp = Regexp.new("^(#{command_names}) #{source}$", Regexp::IGNORECASE)
        adv_define(regexp, class_name, modifiers, &block)
      end
      
      # A more advanced, manual version of +define+.
      #
      # When a command is looked up, the regexp used here will be tested against the
      # command, and if it matches, the block will be yielded, receiving the
      # MatchData object. To be useful, the block should return whichever captures
      # you want to be passed on to the Command instance.
      #
      # +modifiers+ is an optional hash that lets you define local modifiers on
      # the command, where keys are symbols and values are regexps. You can leave
      # a value nil if the regexp is the same as the symbol.
      #
      # If you do not supply a block then by default all captures from the regexp
      # will be passed on to the Command.
      #---
      # TODO: Don't need this anymore?
      def adv_define(regexp, class_name, modifiers={}, &block)
        raise ArgumentError, 'First argument to adv_define must be a Regexp' unless regexp.is_a?(Regexp)
        block ||= proc {|match| (match.captures.empty? ? match.to_a : match.captures) }
        klass = Command.const_get(class_name)
        modifiers.keys.each {|modifier| modifiers[modifier] ||= /^#{modifier}$/ }
        commands[klass] = { :regexp => regexp, :block => block, :modifiers => modifiers }
      end

      # This lets you write e.g. [% foo %] to refer to a 'foo' variable instead of
      # having to say [% var foo %]
      #---
      # TODO: Don't need this anymore?
      def global_var(regexp)
        regexp = /^(#{Regexp.escape(regexp.to_s)}(?:\.\w+\??)*)(?:\s:(\w+))?$/ unless regexp.is_a?(Regexp)
        adv_define(regexp, 'Value')
      end
      
      # Defines a command that can be used to modify all commands in the lexicon.
      #
      # First argument is a symbol, the name of the modifier. You can either pass a
      # regexp or a block as the second argument; if you pass a regexp it gets
      # converted to a block. In either case #modifies? ends up calling this block,
      # passing whichever command object was passed to it to the block itself, so you
      # can use the command object in the regexp if you need to.
      #
      # Note that if a local modifier with the same name as a global modifier is
      # defined, then it takes precedence to the global modifier.
      #---
      # TODO: Don't need this anymore?
      def global_modifier(modifier, regexp=nil, &block)
        unless regexp.nil? ^ block.nil?
          raise ArgumentError, "Second argument to global_modifier must be either a regexp or a block (but not both)"
        end
        block = proc {|modifiee| regexp } if regexp
        modifiers[modifier.to_sym] = block
      end
      
      # If passed with arguments, defines a command that can be used to close all
      # (Stackable) commands in the lexicon. Arguments are same for .global_modifier.
      # Note: whereas you can define multiple global modifiers, there can only be one
      # global closer defined, since there is no closers hash. Usually the closer will
      # be 'end'.
      #
      # If passed with no arguments, returns the closer.
      #---
      # TODO: Don't need this anymore?
      def closer(*args, &block)
        if args.empty?
          @closer
        else
          name, regexp = *args
          unless regexp.nil? ^ block.nil?
            raise ArgumentError, "Second argument to closer must be either a regexp or a block (but not both)"
          end
          block = proc {|modifiee| regexp } if regexp
          @closer = { :name => name.to_sym, :block => block }
        end
      end
      
    end
  end
end