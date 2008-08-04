module PageTemplate
  # This is the regexp we tried using for grabbing an entire line
  # Good for everything but a Value command :-/.
  # /(?:^\s*\[%([^\]]+?)%\]\s*$\r?\n?|\[%(.+?)%\])/m,
  class DefaultLexicon < Lexicon
    command_open  '[%'
    command_close '%]'

    adv_define %r/^--(.+)$/i, 'Comment'
    
    define :var,     /((?:\w+)(?:\.\w+\??)*)(?:\s+:(\w+))?/i, :class_name => 'Value'
    define :define,  /(\w+)\s+?(.+)/
    define :filter,  /:(\w+)/
    define :if,      /(\w+(?:\.\w+\??)*)/, :also => :unless
    define :loop,    /(\w+(?:\.\w+\??)*)(?:\:((?:\s+\w+)+))?/, :also => :in
    define :include, /(\w+(?:\.\w+\??)*)/
    define :case,    /(\w+(?:\.\w+)*)/

    # Command#else's expect only to be called
    modifier(:else) {|modifiee, raw_command|
      case raw_command
      when /^(else|no|empty)$/i
        modifiee.else
        true
      else
        false
      end
    }

    # elsif: accepts else and elsif
    modifier(:elsif) {|modifiee, raw_command|
      case raw_command
      when /^(?:elsif|elseif|else if) (.+)$/i
        modifiee.elsif($1)
        true
      when /^(else|no|empty)$/i
        modifiee.else
        true
      else
        false
      end
    }

    # Command#end
    # accepts 'end', 'end(name)' and 'end (name)'
    modifier(:end) {|modifiee, raw_command|
      case raw_command
      when /^end\s*(#{modifiee.called_as})?$/i
        modifiee.end
        true
      else
        false
      end
    }
    # For case statements.
    modifier(:when) {|modifiee, raw_command|
      case raw_command
      when /^when\s+(\w(?:.\w+\??)*)$/i
        modifiee.when($1)
        true
      when /^else$/i
        modifiee.else
        true
      else
        false
      end
    }
  end
end