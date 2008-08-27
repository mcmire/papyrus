module Papyrus
  # A NodeList provides a single interface to multiple Node objects. As it is a
  # Node itself, it has output and parent methods. A NodeList is also a context object,
  # so it can store and retrieve values easily.
  class NodeList < Node
    include ContextItem
    
    attr_reader :nodes
    
    # Creates a new NodeList. Any arguments passed are dished off to Node's constructor.
    def initialize(*args)
      super
      @nodes = []
    end
    
    for meth in [ :length, :size, :first, :last, :empty? ]
      class_eval <<-EOT, __FILE__, __LINE__
        def #{meth}
          @nodes.send(:#{meth})
        end
      EOT
    end
    def [](i)
      @nodes[i]
    end

    # Adds the given node to the NodeList.
    #
    # A TypeError is raised if the object being added is not a Node.
    #
    # Note: This is also aliased as <<
    def add(node)
      raise TypeError, 'NodeList#add: Attempt to add non-Node object' unless node.kind_of?(Node)
      @nodes << node
      self
    end
    def <<(node)
      add(node)
    end

    # Calls #output on each Node contained in the NodeList, joining all the output
    # in a single string.
    def output
      @nodes.inject("") {|str, node| str << node.output }
    end
    
    def to_s
      '[ NodeList: ' + @nodes.map {|node| "[#{node.to_s}]" }.join(' ') + ' ]'
    end
  end
end