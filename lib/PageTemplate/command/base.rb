class PageTemplate
  module Command
    # Command classes generate text output based on conditions which vary
    # between each class. Command::Base provides an abstract base class to show
    # interface.
    class Base
      attr_reader :called_as
      class << self
        attr_reader :modifier, :closer
      end

      # Subclasses of Command::Base use the output method to generate their text
      # output.  +context+ is a Context object, which may be required by 
      # a particular subclass.
      #
      # Command#output must return a string
      def output(context = nil)
        raise NotImplementedError, 
              "output() must be implemented by subclasses"
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