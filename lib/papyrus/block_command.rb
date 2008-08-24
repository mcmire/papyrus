module Papyrus
  # A BlockCommand is a command that has a start tag, an end tag, and possibly
  # modifier tags. The content between tags may span multiple lines.
  class BlockCommand < Command
    # A BlockCommand has its own context
    include ContextItem
    
    def initialize(*args)
      raise TypeError, 'BlockCommand.new should not be called directly' if self.class == BlockCommand
      super
    end
    
    def active_block
      raise NotImplementedError, 'BlockCommand#active_block should be overridden by a subclass'
    end
    
    def add(cmd)
      active_block << cmd
      self
    end
    def <<(cmd)
      add(cmd)
    end
    
    alias_method :_get, :get
    def get(key)
      active_block.get(key)
    end
    
    def to_s
      "[ #{@name} ]"
    end
  end
end