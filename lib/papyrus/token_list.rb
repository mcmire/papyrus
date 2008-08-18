module Papyrus
  class TokenList < ::Array    
    attr_accessor :pos, :cmd_info
    
    def initialize(array = [])
      super(array)
      @pos = -1
      @cmd_info = { :raw => "", :full => "" }
      @record = false
    end
    
    def advance
      tok = nil
      # skip whitespace, but still record it
      begin
        @pos += 1
        tok = self[@pos]
        if @record
          @cmd_info[:raw] << tok
          @cmd_info[:full] << tok unless tok.is_a?(Token::LeftBracket) or tok.is_a?(Token::RightBracket)
        end
      end while tok.is_a?(Token::Whitespace)
      tok
    end
    
    #def skip(klass)
    #  tok = nil
    #  begin; tok = self.next; end while tok.is_a?(klass)
    #  tok
    #end
    
    def curr
      self[@pos]
    end
    
    def next
      self[@pos+1]
    end
    
    def prev
      self[@pos-1]
    end
    
    def start_recording!
      @record = true
    end
    
    def stop_recording!
      @record = false
      @cmd_info = { :raw => "", :full => "" }
    end
    
    def save
      # ...
    end
    
    def revert
      # ...
    end
  end
end