module Papyrus
  # A NodeList provides a single interface to multiple Node objects. As it is a
  # Node itself, it has an output method.
  class NodeList < Node
    include ContextItem
    
    attr_reader :nodes
    
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

    # Adds +node+ to the NodeList.
    # A TypeError is raised if the object being added is not a Node.
    #
    # This is also aliased as <<
    def add(node)
      raise TypeError, 'NodeList#add: Attempt to add non-Node object' unless node.kind_of?(Node)
      @nodes << node
      self
    end
    def <<(node)
      add(node)
    end

    # Calls Node#output(context) on each Node contained in this 
    # object.  The output is returned as a single string.  If no output
    # is generated, returns an empty string.
    def output
      @nodes.inject("") {|str, node| str << node.output }
    end
    
    # Returns Nodes held, as a string
    def to_s
      '[ NodeList: ' + @nodes.map {|node| "[#{node.to_s}]" }.join(' ') + ' ]'
    end
  end
end