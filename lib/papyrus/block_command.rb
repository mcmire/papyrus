module Papyrus
  # A BlockCommand is a command that has a start tag, an end tag, and possibly
  # modifier tags. The content between tags may span multiple lines.
  class BlockCommand < Command
    # A BlockCommand has its own context
    include ContextItem
    
    def initialize(*args)
      raise NotImplementedError, 'BlockCommand.new should not be called directly' if self.class == BlockCommand
      super
    end
    
    def active_block
      raise NotImplementedError, 'BlockCommand#active_block should not be called directly' if self.class == BlockCommand
      raise 'BlockCommand#active_block: @active_block should have been set in constructor' unless @active_block
      @active_block
    end
    
    def add(cmd)
      active_block << cmd
      self
    end
    def <<(cmd)
      add(cmd)
    end
    
    def to_s
      "[ #{@name} ]"
    end
  end
end