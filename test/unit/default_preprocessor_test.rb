require File.dirname(__FILE__)+'/test_helper'

require 'default_preprocessor'

Expectations do
  
  expect "some string" do
    PageTemplate::DefaultPreprocessor.unescaped("some string")
  end
  
  expect "gnirts emos" do
    PageTemplate::DefaultPreprocessor.reverse("some string")
  end
  
  expect "bar+quuz%3C%3E%40%28%29%26%3Fflue%3Dbuzx" do
    PageTemplate::DefaultPreprocessor.escapeURI("bar quuz<>@()&?flue=buzx")
  end
  
  expect "&lt;b&gt;This &lt;i&gt;should&lt;/i&gt; be &quot;escaped&quot; &amp; stuff&lt;/b&gt;" do
    PageTemplate::DefaultPreprocessor.escapeHTML('<b>This <i>should</i> be "escaped" & stuff</b>')
  end
  
  expect "&lt;b&gt;This &lt;i&gt;should&lt;/i&gt; be &quot;escaped&quot;<br />\n &amp; stuff&lt;/b&gt;" do
    PageTemplate::DefaultPreprocessor.simple("<b>This <i>should</i> be \"escaped\"\n & stuff</b>")
  end
  
end