require File.dirname(__FILE__)+'/../test_helper'

Box = Struct.new(:height, :width)

Expectations do
  
  # loop with no block param
  expect "5x5 10x10 20x20" do
    source = "[for boxes][height]x[width] [/for]"
    parse(source, 'boxes' => [ Box.new(5,5), Box.new(10,10), Box.new(20,20) ])
  end
  
  # looping over simple array with one block param
  expect "5x5 10x10 20x20" do
    source = "[for box in boxes][box.height]x[box.width] [/for]"
    parse(source, 'boxes' => [ Box.new(5,5), Box.new(10,10), Box.new(20,20) ])
  end
  
  # looping over hash with two block params
  expect "height: 10, width: 20," do
    source = "[foreach k v in hash][k]: [v], [/foreach]"
    parse(source, 'hash' => { 'height' => '10', 'width' => '20' })
  end
  
end