#!/usr/local/bin/ruby -w

# Papyrus is a heavily modified version of PageTemplate
# http://coolnamehere.com/products/pagetemplate/

##############################################################################

require 'ruby_ext'

require 'papyrus/command'

require 'papyrus/context_item'
require 'papyrus/context'

require 'papyrus/lexicon'
require 'papyrus/default_lexicon'

require 'papyrus/preprocessor'
require 'papyrus/default_preprocessor'

require 'papyrus/source'
require 'papyrus/file_source'
require 'papyrus/string_source'

require 'papyrus/compiler'
require 'papyrus/parser'

require 'papyrus/template'

##############################################################################

# Papyrus is just the namespace for all of its real code, so as
# not to caues confusion or clashes with the programmer's code.
module Papyrus
  VERSION = "2.2.3-modified"

  # Passes arguments straight to Compiler.new. Returns a Compiler object.
  def self.new(*args)
    Compiler.new(*args)
  end
end