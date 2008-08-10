require File.dirname(__FILE__)+'/spec_helper'

describe Papyrus do

  it "should successfully parse a template from a file" do
    template = Papyrus.new(:include_path => File.dirname(__FILE__))
    template.load('sample.txt')
    template[:words] = %w(red blue orange green yellow)
    template[:wanker] = "Steve"
    expected_content = File.open(File.dirname(__FILE__)+'/sample_compiled.txt') {|f| f.read }
    template.output.should == expected_content
  end
  
  it "should successfully parse a template from a file" do
    
  end

end