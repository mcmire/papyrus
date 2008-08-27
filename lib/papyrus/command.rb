require 'set'

module Papyrus
  # A Command is a Node that represents a substitution (e.g. [foo], or [foo bar]) in
  # the source template. As a result, it will be evaluated into a string when the
  # template is parsed.
  class Command < Node
    class << self
      # Returns the list of command modifiers for this Command class.
      def modifiers
        @modifiers ||= Set.new
      end
      # Defines a modifier by defining a method by the given name and adding
      # the modifier to the list of modifiers.
      def modifier(name, &block)
        name = name.to_sym
        define_method(name, &block)
        self.modifiers << name
      end
      
      # Returns the list of aliases for this Command class.
      def aliases
        @aliases ||= Set.new
      end
      # Defines aliases for this command.
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
    
    # If this command is a BlockCommand, and this command has a method with the same
    # name as the given modifier, the method is called and its return value is returned.
    # Otherwise, false is returned.
    #
    # This is used by Parser to both check and run a modifier on the currently
    # active command.
    def modified_by?(modifier, args)
      is_a?(BlockCommand) or return false
      respond_to?(modifier) or return false
      send(modifier, args)
    end
  end
end