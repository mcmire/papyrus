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

require 'papyrus/filter'

require 'papyrus/template'
require 'papyrus/token'
require 'papyrus/token_list'
require 'papyrus/parser'

##############################################################################

module Papyrus
  class << self
    def source_template_dirs; @source_template_dirs ||= %w(.); end
    attr_accessor :available_commands, :cached_template_dir
    attr_writer :cache_templates

    # Loads command classes and creates a new instance of Compiler
    def new(*args)
      Parser.new(*args)
    end
    
    def lexicon
      @lexicon ||= {}
    end
    
    def cache_templates?
      @cache_templates
    end

    # Load commands based on available_commands, or load all
    def load_command_classes
      available_commands = Papyrus.available_commands || Dir[File.dirname(__FILE__)+"/papyrus/commands/*.rb"].map {|file| File.basename(file, '.rb') }
      for name in available_commands
        name = name.to_s
        require "papyrus/commands/#{name}"
        klass = Commands.const_get(name.camelize)
        names = [name] + klass.aliases.map {|x| x.to_s }
        names.each {|n| lexicon[n] = klass }
      end
    end
  end
end