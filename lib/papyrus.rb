#!/usr/local/bin/ruby -w

# Papyrus is a heavily modified version of PageTemplate 2.2.3
# Original source can be located at http://coolnamehere.com/products/pagetemplate/

##############################################################################

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'ruby_ext'

require 'papyrus/context_item'
require 'papyrus/context'

require 'papyrus/node'
require 'papyrus/node_list'
require 'papyrus/text'
require 'papyrus/variable'
require 'papyrus/command'
require 'papyrus/block_command'

#require 'papyrus/lexicon'
#require 'papyrus/default_lexicon'

#require 'papyrus/preprocessor'
require 'papyrus/default_preprocessor'

#require 'papyrus/source'
#require 'papyrus/file_source'
#require 'papyrus/string_source'

require 'papyrus/template'
require 'papyrus/token'
require 'papyrus/token_list'
require 'papyrus/parser'
#require 'papyrus/compiler'

##############################################################################

module Papyrus
  class << self
    def source_template_dirs; @source_template_dirs ||= %w(.); end
    attr_accessor :available_commands, :cached_template_dir
    attr_reader :lexicon

    # Loads command classes and creates a new instance of Compiler
    def new(*args)
      @lexicon = {}
      load_command_classes
      Compiler.new(*args)
    end

    # Load commands based on available_commands, or load all
    def load_command_classes
      available_commands = Papyrus.available_commands || Dir[File.dirname(__FILE__)+"/papyrus/commands/*.rb"].map {|file| File.basename(file, '.rb') }
      available_commands.each do |name|
        name = name.to_s
        require "papyrus/commands/#{name}"
        klass = Commands.const_get(name.camelize)
        names = [name] + klass.aliases.map {|x| x.to_s }
        names.each {|n| @lexicon[n] = klass }
      end
    end
  end
end