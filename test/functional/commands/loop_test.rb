require File.dirname(__FILE__)+'/../test_helper'

Box = Struct.new(:height, :width)

Expectations do
  
  # loop with no block param
  expect "1 2 3 4" do
    source = "[loop boxes][size]
  
end