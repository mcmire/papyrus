module Papyrus
  # A Variable is a Node that represents a simple substitution (e.g. [foo]) that
  # could not be interpreted as a Command (because it doesn't exist or whatever).
  # We don't actually know if the variable exists, however, until we output it.
  class Variable < Node

    # Creates a new Variable, storing the given name and the raw command
    # (the entire sub).
    def initialize(*args)
      @name, @raw_command = super
    end

    # Looks for the variable in the parent context and returns the resulting value
    # if it exists there, or the raw command otherwise.
    def output
      (value = parent.get(@name)).nil? ? @raw_command : value.to_s
    end

    def to_s
      "[ Variable: #{@name} ]"
    end
  end
end