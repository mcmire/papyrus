module Papyrus
  # A Node is used in the parsing process. It is defined as something that can be
  # evaluated into a string using its +output+ method. In addition, every Node has
  # a parent, in case we need to look up the ancestry for information.
  class Node
    attr_accessor :parent
    
    # Creates a new node, storing the given parent. Any other arguments to the
    # Node are returned so that subclasses can handle them.
    def initialize(*args)
      @parent = args.shift
      args
    end
    
    # Subclasses of Node use the output method to generate their text output.
    def output
      raise NotImplementedError, "output() must be implemented by subclasses"
    end

    def to_s
      "[ #{self.class} ]"
    end
  end
end