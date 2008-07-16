class PageTemplate
  # This is the regexp we tried using for grabbing an entire line
  # Good for everything but a Value command :-/.
  # /(?:^\s*\[%([^\]]+?)%\]\s*$\r?\n?|\[%(.+?)%\])/m,
  class DefaultLexicon < Lexicon
    @sub_regex = /\[%(.+?)%\]/m

    default { |command|
      Command::Unknown.new(command)
    }

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
    modifier(:else) { |cmd,command|
      puts "Uh, whoops? #{command}" if command =~ /tmpl/mi
      case command
      when /^(else|no|empty)$/i
        cmd.else
        true
      else
        false
      end
    }

    # elsif: accepts else and elsif
    modifier(:elsif) { |cmd,command|
      case command
      when /^(?:elsif|elseif|else if) (.+)$/i
        cmd.elsif($1)
        true
      when /^(else|no|empty)$/i
        cmd.else
        true
      else
        false
      end
    }

    # Command#end
    # accepts 'end', 'end(name)' and 'end (name)'
    modifier(:end) { |cmd,command|
      case command
      when /^end\s*(#{cmd.called_as})?$/i
        cmd.end
        true
      else
        false
      end
    }
    # For case statements.
    modifier(:when) { |cmd,command|
      case command
      when /^when\s+(\w(?:.\w+\??)*)$/i
        cmd.when($1)
        true
      when /^else$/i
        cmd.else
        true
      else
        false
      end
    }
  end
end