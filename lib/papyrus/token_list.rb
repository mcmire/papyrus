module Papyrus
  class TokenList < ::Array    
    attr_accessor :pos, :cmd_info
    
    def initialize(array = [])
      super(array)
      @pos = -1
      @cmd_info = { :raw => "", :full => "" }
      @stash_curr_on_advance = false
    end
    
    def advance
      token = nil
      # skip whitespace, but still record it
      begin
        @pos += 1
        token = self[@pos]
        stash_curr if @stash_curr_on_advance
      end while token.is_a?(Token::Whitespace)
      token
    end
    
    def curr
      self[@pos]
    end
    
    def next
      self[@pos+1]
    end
    
    def prev
      self[@pos-1]
    end
    
    def start_stashing!
      @stash_curr_on_advance = true
      @cmd_info = { :raw => "", :full => "" }
    end
    
    def stop_stashing!
      @stash_curr_on_advance = false
    end
    
    def stash_curr
      token = self.curr
      cmd_info[:raw] << token
      cmd_info[:full] << token unless token.is_a?(Token::LeftBracket) or token.is_a?(Token::RightBracket)
    end
  end
end