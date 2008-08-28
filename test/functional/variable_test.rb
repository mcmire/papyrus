require File.dirname(__FILE__)+'/test_helper'

Expectations do
  
  # variable doesn't exist
  expect "[nonexistent_variable]" do
    parse("[nonexistent_variable]")
  end
  
  # simple variable
  expect "bar" do
    parse("[foo]", 'foo' => 'bar')
  end
  
  # two part variable
  expect "baz" do
    parse("[foo.bar]", 'foo' => { 'bar' => 'baz' })
  end
  
  # three part variable when nil is returned midway
  expect "[foo.bar.baz]" do
    parse("[foo.bar.baz]", 'foo' => { 'bar' => nil })
  end
  
end