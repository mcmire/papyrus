require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'context'

include Papyrus

Expectations do
  
  expect Hash do
    Context.new.send :instance_variable_get, '@vars'
  end
  expect Context do
    parent_context = Context.new
    context = Context.new(parent_context)
    context.send :instance_variable_get, '@parent'
  end
  expect "" do
    context = Context.new(nil, "")
    context.send :instance_variable_get, '@object'
  end
  
  expect Context do
    Context.construct_from({})
  end
end