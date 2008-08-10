require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'context'

Expectations do
  
  expect Hash do
    Papyrus::Context.new.send :instance_variable_get, '@values'
  end
  expect Papyrus::Context do
    parent_context = Papyrus::Context.new
    context = Papyrus::Context.new(parent_context)
    context.send :instance_variable_get, '@parent'
  end
  expect "" do
    context = Papyrus::Context.new(nil, "")
    context.send :instance_variable_get, '@object'
  end
  
  expect Papyrus::Context do
    Papyrus::Context.construct_from({})
  end
end