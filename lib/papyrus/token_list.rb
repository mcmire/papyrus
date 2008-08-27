module Papyrus
  # A TokenList is, well, a list of tokens. In fact it's nothing more than an Array
  # that has the ability to step through its items one at a time and know which
  # item it's currently on.
  class TokenList < ::Array
    # The token pointer, i.e., the index of the token that's currently selected.
    attr_accessor :pos
    # The stash is used to store a raw command (including brackets) and full command
    # (without brackets).
    attr_accessor :stash
    
    # Creates a new TokenList, optionally initializing the list with the given array.
    def initialize(array = [])
      super(array)
      @pos = -1
      @stash = { :raw => "", :full => "" }
      @stash_curr_on_advance = false
    end
    
    # Increments the token pointer and returns the token at that index. Whitespace
    # tokens will be skipped over.
    #
    # If @stash_curr_on_advance is true, everything that's encountered will be
    # stored in the @stash, even whitespace.
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
    
    # Returns the currently selected token.
    def curr
      self[@pos]
    end
    
    # Returns the token following the current one.
    def next
      self[@pos+1]
    end
    
    # Returns the token before the current one.
    def prev
      self[@pos-1]
    end
    
    # Notes that tokens should be stashed on calls to #advance, and initializes
    # the stash.
    def start_stashing!
      @stash_curr_on_advance = true
      @stash = { :raw => "", :full => "" }
    end
    
    # Notes that tokens should no longer be stashed on calls to #advance.
    def stop_stashing!
      @stash_curr_on_advance = false
    end
    
    # Gets the current token and appends it to the raw command string, also appending
    # it to the full command string unless it's a left or right bracket.
    def stash_curr
      token = self.curr
      stash[:raw] << token
      stash[:full] << token unless token.is_a?(Token::LeftBracket) or token.is_a?(Token::RightBracket)
    end
  end
end