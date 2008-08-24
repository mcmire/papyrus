module Papyrus
  # Nodes are used in the parsing process. It is defined as something that can be
  # evaluated into a string using its +output+ method.
  class Node
    attr_accessor :parent
    
    def initialize(*args)
      @parent = args.shift
      args
    end
    
    # Subclasses of Node use the output method to generate their text output.
    # +context+ is a Context object, which may be required by a particular
    # subclass. A string must be returned.
    def output
      raise NotImplementedError, "output() must be implemented by subclasses"
    end

    def to_s
      "[ #{self.class} ]"
    end
  end
end