require File.dirname(__FILE__)+'/test_helper'

require 'source'

Expectations do
  
  # Source.initialize
  expect(:foo => 'bar', :baz => 'quux') do
    source = Papyrus::Source.new(:foo => 'bar', :baz => 'quux')
    source.send :instance_variable_get, :@options
  end
  
  # Source#get when nil passed
  expect nil do
    source = Papyrus::Source.new
    source.get
  end
  # Source#get when non-nil value passed
  expect "something" do
    source = Papyrus::Source.new
    source.get("something")
  end
  
end