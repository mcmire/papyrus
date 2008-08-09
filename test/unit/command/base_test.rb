require File.dirname(__FILE__)+'/../test_helper'

require 'command/base'
require 'command/stackable'

module PageTemplate
  module Command
    class Foo < Stackable
    end
  end
end

Expectations do
  
  # Base#initialize
  begin
    expect :lexicon do
      PageTemplate::Command::Base.new(:lexicon).send(:instance_variable_get, "@lexicon")
    end
    expect "foo" do
      PageTemplate::Command::Base.new(nil, "foo").send(:instance_variable_get, "@called_as")
    end
  end
  
  # Base#modified_by?
  begin
    # when command is not a Stackable
    expect false do
      PageTemplate::Command::Base.new.modified_by?('')
    end
    # when not lexicon.modifier_on
    expect false do
      foo = PageTemplate::Command::Foo.new
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => nil)
      foo.modified_by?('')
    end
    # when does not respond_to?(modifier)
    expect false do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:foo, match])
      foo.modified_by?('')
    end
    # when method returns false
    expect false do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:end, match])
      foo.stubs(:end).returns(false)
      foo.modified_by?('')
    end
    # when method returns true
    expect true do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :modifier_on => [:end, match])
      foo.stubs(:end).returns(true)
      foo.modified_by?("")
    end
  end
  
  # Base#closed_by?
  begin
    # when command is not a Stackable
    expect false do
      PageTemplate::Command::Base.new.closed_by?('')
    end
    # when not lexicon.closer_on
    expect false do
      foo = PageTemplate::Command::Foo.new
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => nil)
      foo.closed_by?('')
    end
    # when does not respond_to? modifier
    expect false do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:foo, match])
      foo.closed_by?('')
    end
    # when method returns false
    expect false do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:end, match])
      foo.stubs(:end).returns(false)
      foo.closed_by?('')
    end
    # when method returns true
    expect true do
      foo = PageTemplate::Command::Foo.new
      match = stub('match', :captures => [], :to_a => [])
      foo.stubs(:lexicon).returns stub('lexicon', :closer_on => [:end, match])
      foo.stubs(:end).returns(true)
      foo.closed_by?("")
    end
  end
  
  # Base#output
  expect NotImplementedError do
    PageTemplate::Command::Base.new.output
  end
  
  # Base#to_s
  expect "[ PageTemplate::Command::Base ]" do
    PageTemplate::Command::Base.new.to_s
  end
  
end