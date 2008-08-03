require File.dirname(__FILE__)+'/test_helper'

require 'context_item'
require 'context'

Expectations do
  
  expect Hash do
    PageTemplate::Context.new.send :instance_variable_get, '@values'
  end
  expect PageTemplate::Context do
    parent_context = PageTemplate::Context.new
    context = PageTemplate::Context.new(parent_context)
    context.send :instance_variable_get, '@parent'
  end
  expect "" do
    context = PageTemplate::Context.new(nil, "")
    context.send :instance_variable_get, '@object'
  end
  
  expect PageTemplate::Context do
    PageTemplate::Context.construct_from({})
  end
end