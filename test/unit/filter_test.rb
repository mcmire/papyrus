require File.dirname(__FILE__)+'/test_helper'

require 'filter'

include Papyrus

Expectations do
  
  # Filters.unescaped
  begin
    expect "Here is some text" do
      Filters.unescaped("Here is some text")
    end
    expect "txet emos si ereH" do
      Filters.reverse("Here is some text")
    end
    expect "http%3A%2F%2Fblah.com%2Ffoo+bar+baz+%21%21%5C%2A%2A%C6%92%C3%9F%E2%84%A2%C3%9F%C2%BA%C2%BA" do
      Filters.escape_uri("http://blah.com/foo bar baz !!\\**ƒß™ßºº")
    end
    expect "This is some &lt;b&gt;bold&lt;/b&gt; text" do
      Filters.escape_html("This is some <b>bold</b> text")
    end
    expect "Here is one line<br />\nHere is another" do
      Filters.nl2br("Here is one line\nHere is another")
    end
  end
  
  # Filter.filter
  begin
    # when Filters.respond_to?(filter)
    expect Filters.to.receive(:reverse).with("Some string") do
      Filter.filter("reverse", "Some string")
    end
    # when not Filters.respond_to?(filter)
    expect Filters.to.receive(:unescaped).with("Some string") do
      Filter.filter("unescaped", "Some string")
    end
  end
  
end