require File.dirname(__FILE__)+'/../test_helper'

Expectations do

  # if
  expect "Some text and stuff" do
    source = <<-EOT
      [if foo]
        Some text and stuff
      [/if]
    EOT
    parse(source, 'foo' => true)
  end
  
  # else
  expect "Cool stuff" do
    source = <<-EOT
      [if foo]
        This text should not be returned
      [else]
        Cool stuff
      [/if]
    EOT
    parse(source)
  end
  
  # elsif
  expect "mhmmmm" do
    source = <<-EOT
      [if xyzzy]
        Some text and stuff
      [elsif blargh]
        mhmmmm
      [/if]
    EOT
    parse(source, 'blargh' => "some value")
  end
  
  # unless
  expect "Didn't expect this to be returned, did you??" do
    source = <<-EOT
      [unless some_variable_exists]
        Didn't expect this to be returned, did you??
      [else]
        This won't be returned
      [/unless]
    EOT
    parse(source)
  end

end