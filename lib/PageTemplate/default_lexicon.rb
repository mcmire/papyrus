module PageTemplate
  # This is the regexp we tried using for grabbing an entire line
  # Good for everything but a Value command :-/.
  # /(?:^\s*\[%([^\]]+?)%\]\s*$\r?\n?|\[%(.+?)%\])/m,
  class DefaultLexicon < Lexicon
    @command_regex = /\[%(.+?)%\]/m
    
    # TODO: Unknown command should be the default in the Lexicon

    default { |command_contents|
      Command::Unknown.new(command_contents)
    }
    
    # TODO: This should look more like:
    #   define /.../, Command::Value
    # The class should be automatic (although you can override it)
    # All captures should be passed to the instance automatically
    # (although you can override that too)

    define(/^var ((?:\w+)(?:\.\w+\??)*)(?:\s+:(\w+))?$/i) { |match|
      # Value, Preprocessor
      Command::Value.new(match[1],match[2])
    }

    define(/^--(.+)$/i) { |match|
    # The Comment
      Command::Comment.new(match[1])
    }

    define(/^define (\w+)\s+?(.+)$/i) { |match|
      Command::Define.new(match[1], match[2])
    }

    define(/^filter :(\w+)$/i) { |match|
      Command::Filter.new(match[1])
    }

    define(/^(if|unless) ((\w+)(\.\w+\??)*)$/i) { |match|
      # Called_As, Value
      Command::If.new(match[1],match[2])
    }

    define(/^(in|loop) (\w+(?:\.\w+\??)*)(?:\:((?:\s+\w+)+))?$/i) { |match|
      # Called_As, Value, Iterators
      Command::Loop.new(match[1],match[2],match[3])
    }

    define(/^include ((\w+)(?:\.\w+\??)*)$/i) { |match|
      # Value
      Command::Include.new(match[1])
    }
    
    define(/^case (\w+(?:\.\w+)*)$/) { |match|
      Command::Case.new(match[1])
    }

    # Command#else's expect only to be called
    modifier(:else) { |modifiee,command_contents|
      puts "Uh, whoops? #{command_contents}" if command_contents =~ /tmpl/mi
      case command_contents
      when /^(else|no|empty)$/i
        modifiee.else
        true
      else
        false
      end
    }

    # elsif: accepts else and elsif
    modifier(:elsif) { |modifiee,command_contents|
      case command_contents
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
    modifier(:end) { |modifiee,command_contents|
      case command_contents
      when /^end\s*(#{modifiee.called_as})?$/i
        modifiee.end
        true
      else
        false
      end
    }
    # For case statements.
    modifier(:when) { |modifiee,command_contents|
      case command_contents
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