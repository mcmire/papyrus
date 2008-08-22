require File.dirname(__FILE__)+'/spec_helper'

describe Papyrus do

  it "should successfully parse a template from a file" do
    Papyrus.source_template_dirs += File.dirname(__FILE__)
    template = Papyrus::Template.load('sample.txt')
    template.vars = {
      :words => %w(red blue orange green yellow),
      :wanker => "Steve"
    }
    expected_content = File.open(File.dirname(__FILE__)+'/sample_compiled.txt') {|f| f.read }
    template.output.should == expected_content
  end
  
  it "should successfully parse a template from a file" do
    
  end

end