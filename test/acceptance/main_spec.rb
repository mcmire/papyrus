require File.dirname(__FILE__)+'/spec_helper'

describe Papyrus do

  it "should successfully parse a template from a file" do
    this_dir = File.dirname(__FILE__)
    #Papyrus.cache_templates = true
    Papyrus.cached_template_dir = File.join(this_dir, 'cached')
    Papyrus.source_template_dirs.unshift(this_dir)
    output = Papyrus::Parser.parse_file('sample.txt', {
      'words' => %w(red blue orange green yellow),
      'blah' => "Steve",
      'hash' => { 'table' => "Wheeeee" }
    })
    File.open(File.dirname(__FILE__)+'/sample.compiled.txt', "w") {|f| f.write(output) }
    #puts "ACTUAL"
    #puts output
    #puts
    expected_output = File.open(File.dirname(__FILE__)+'/sample_compiled.txt') {|f| f.read }
    #puts "EXPECTED"
    #puts expected_output
    output.should == expected_output
  end

end