require File.dirname(__FILE__)+'/../test_helper'

Expectations do
  
  # argument is a variable
  expect "Schmoe" do
    source = <<-EOT
      [case first]
        [when Steve] Jobs
        [when Joe] Schmoe
        [when George] Michael
      [/case]
    EOT
    parse(source, 'first' => 'Joe')
  end
  
  # argument is a literal
  expect "is the best number" do
    source = <<-EOT
      [case 42]
        [when 30] your mom
        [else] is the best number
      [/case]
    EOT
    parse(source)
  end
  
  # everything is converted to a string
  expect "this is kind of like Javascript" do
    source = <<-EOT
      [case "80"]
        [when 80] this is kind of like Javascript
      [/case]
    EOT
    parse(source)
  end
  
end