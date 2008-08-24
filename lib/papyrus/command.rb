require 'set'

module Papyrus
  # Commands correspond to tags in the template code. As they are Nodes, they are
  # evaluated into strings when the template is parsed.
  class Command < Node
    class << self
      def modifiers
        @modifiers ||= Set.new
      end
      def modifier(name, &block)
        name = name.to_sym
        define_method(name, &block)
        self.modifiers << name
      end
      
      def aliases
        @aliases ||= Set.new
      end
      def aka(*aliases)
        self.aliases # init set
        @aliases += aliases
      end
    end
    
    attr_reader :name, :args
    
    # Creates a new instance of the Command.
    # Stores the name this command was called as and the arguments.
    def initialize(*args)
      @name, @args = super
    end
    
    # If this command is a BlockCommand, and +full_command+ refers to a valid modifier
    # of this command, and this command has a method with the same name as the 
    # modifier, the method is called and its return value is returned.
    # Otherwise, false is returned.
    #
    # This is used by Parser to both check and run a modifier on the currently
    # active command.
    def modified_by?(modifier, args)
      is_a?(BlockCommand) or return false
      respond_to?(modifier) or return false
      send(modifier, args)
    end
    
    # If this command is a BlockCommand, and +full_command+ refers to a valid closer
    # of this command, and this command has a method with the same name as the
    # closer, the method is called and its return value is returned.
    # Otherwise, false is returned.
    #
    # This is used by Parser to both check and run a closer on the currently
    # active command.
    #---
    # XXX: Not needed anymore?
    def closed_by?(full_command)
      is_a?(BlockCommand) or return false
      ret = lexicon.closer_on(full_command, self) or return false
      closer, match = ret
      respond_to?(closer) or return false
      args = match.captures.compact
      send(closer, *args)
    end
  end
end