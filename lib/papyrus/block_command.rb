module Papyrus
  # A BlockCommand is a command that has a start tag, an end tag, and possibly
  # modifier tags. The content between tags may span multiple lines.
  class BlockCommand < Command
    def initialize(*args)
      raise ArgumentError, 'BlockCommand.new should not be called directly' if self.class == BlockCommand
      super
    end
    
    def add(block)
      raise ArgumentError, 'BlockCommand#add should not be called directly'
    end
    def <<(cmd)
      add(cmd)
    end
    
    def to_s
      "[ #{@name} ]"
    end
  end
end