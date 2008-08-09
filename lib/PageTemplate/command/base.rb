module PageTemplate
  module Command
    # Command classes generate text output based on conditions which vary
    # between each class. Command::Base provides an abstract base class to show
    # interface.
    class Base
      attr_reader :lexicon, :called_as
      class << self
        attr_accessor :modifier
        attr_accessor :closer
      end
      
      self.modifier = nil
      self.closer   = nil
      
      # Creates a new instance of the Command. The first argument is assumed to
      # be the name that this command was called as, and stored.
      def initialize(*args)
        @lexicon, @called_as = args
      end
      
      # If this command is a Stackable, and +raw_command+ refers to a valid modifier
      # of this command, and this command has a method with the same name as the 
      # modifier, the method is called and its return value is returned.
      # Otherwise, false is returned.
      #
      # This is used by Parser to both check and run a modifier on the currently
      # active command.
      def modified_by?(raw_command)
        is_a?(Stackable) or return false
        ret = lexicon.modifier_on(raw_command, self) or return false
        modifier, match = ret
        respond_to?(modifier) or return false
        args = match.captures.compact
        send(modifier, *args)
      end
      
      # If this command is a Stackable, and +raw_command+ refers to a valid closer
      # of this command, and this command has a method with the same name as the
      # closer, the method is called and its return value is returned.
      # Otherwise, false is returned.
      #
      # This is used by Parser to both check and run a closer on the currently
      # active command.
      def closed_by?(raw_command)
        is_a?(Stackable) or return false
        ret = lexicon.closer_on(raw_command, self) or return false
        closer, match = ret
        respond_to?(closer) or return false
        args = match.captures.compact
        send(closer, *args)
      end

      # Subclasses of Command::Base use the output method to generate their text
      # output. +context+ is a Context object, which may be required by a particular
      # subclass. A string must be returned.
      def output(context = nil)
        raise NotImplementedError, "output() must be implemented by subclasses"
      end

      # to_s of a Command prints out class and command information, for
      # debugging and visual summary of the template without parsing the
      # outputs.
      def to_s
        "[ #{self.class} ]"
      end
    end
  end
end