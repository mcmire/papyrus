module PageTemplate
  class DefaultLexicon < Lexicon
    bra '[%'
    ket '%]'

    adv_define %r/^--(.+)$/i, 'Comment'
    
    define :var,     /((?:\w+)(?:\.\w+\??)*)(?:\s+:(\w+))?/i, :class_name => 'Value'
    define :define,  /(\w+)\s+?(.+)/
    define :filter,  /:(\w+)/
    define :if,      /(\w+(?:\.\w+\??)*)/, :also => :unless, :modifiers => {
      :else => /^(?:else|no|empty)$/,
      :elsif => /^(?:elsif|elseif|else if) (.+)$/i
    }
    define :loop,    /(\w+(?:\.\w+\??)*)(?:\:((?:\s+\w+)+))?/, :also => :in
    define :include, /(\w+(?:\.\w+\??)*)/
    define :case,    /(\w+(?:\.\w+)*)/, :modifiers => {
      :when => /^when\s+(\w(?:.\w+\??)*)$/i,
      :else => nil
    }
    
    closer(:end) {|modifiee| /^end\s*(?:#{modifiee.called_as})?$/i }
  end
end