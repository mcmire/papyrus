#!/usr/local/bin/ruby -w

# Papyrus is a heavily modified version of PageTemplate
# http://coolnamehere.com/products/pagetemplate/

##############################################################################

$LOAD_PATH.unshift Dir.dirname(__FILE__)

require 'ruby_ext'

require 'papyrus/node'
require 'papyrus/command_block'
require 'papyrus/text'
require 'papyrus/variable'
require 'papyrus/command'
require 'papyrus/block_command'

require 'papyrus/context_item'
require 'papyrus/context'

require 'papyrus/lexicon'
require 'papyrus/default_lexicon'

#require 'papyrus/preprocessor'
require 'papyrus/default_preprocessor'

require 'papyrus/source'
require 'papyrus/file_source'
require 'papyrus/string_source'

require 'papyrus/compiler'
require 'papyrus/parser'
require 'papyrus/template'

##############################################################################

module Papyrus
  VERSION = "2.2.3-modified"
  
  class << self
    attr_accessor :available_commands

    # Loads command classes and creates a new instance of Compiler
    def new(*args)
      load_command_classes
      introspect_command_classes
      Compiler.new(*args)
    end

    # Load commands based on available_commands, or load all
    def load_command_classes
      if Papyrus.available_commands
        Papyrus.available_commands.each {|command| require "papyrus/commands/#{command}" }
      else
        Dir[File.dirname(__FILE__)+"/papyrus/commands/*.rb"].each {|file| require file }
      end
    end
    
    # Gathers and stores info about each command class
    
  end
end