#!/usr/local/bin/ruby -w

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

# Papyrus is the template engine that powers Codexed. It is a heavily modified
# version of the PageTemplate Ruby library written by Brian Wisti and Greg Millam.
#
# (c) 2008 Elliot Winkler
module Papyrus
  class << self
    # Papyrus will look within these locations, and only these locations,
    # for templates you want parsed. Includes the current directory by default.
    def source_template_paths
      @source_template_paths ||= %w(.)
    end
    # When Papyrus comes across a substitution, Papyrus will try to match it
    # against only these commands
    attr_accessor :available_commands
    # The location you want cached (i.e. parsed) templates to go. If not set,
    # Papyrus will put the cached version in the same directory as the source.
    attr_accessor :cached_template_path
    # A boolean indicating whether or not Papyrus should cache templates.
    attr_writer :cache_templates

    # Just a shortcut for +Papyrus::Parser.new(...)+.
    def new(*args)
      Parser.new(*args)
    end
    
    # A mapping of command names to classes that represents which commands
    # Papyrus knows about.
    def lexicon
      @lexicon ||= {}
    end
    
    # Should we cache templates?
    def cache_templates?
      @cache_templates
    end

    # Requires command files and creates a mapping of command names (and aliases)
    # to command classes. We only load commands that are in available_commands, or
    # we load all commands if that hasn't been defined.
    #
    # This will get called the first time a Parser is created.
    def load_command_classes
      return if @loaded_command_classes
      available_commands = Papyrus.available_commands || Dir[File.dirname(__FILE__)+"/papyrus/commands/*.rb"].map {|file| File.basename(file, '.rb') }
      for name in available_commands
        name = name.to_s
        require "papyrus/commands/#{name}"
        klass = Commands.const_get(name.camelize)
        names = [name] + klass.aliases.map {|x| x.to_s }
        names.each {|n| lexicon[n] = klass }
      end
      @loaded_command_classes = true
    end
  end
end