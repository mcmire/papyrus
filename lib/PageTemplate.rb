#!/usr/local/bin/ruby -w

# Use PageTemplate.rb to create output based on template pages and the
# code of your program. This package is inspired by, but not quite
# like, Perl's HTML::Template package. Its main intent is to separate
# design and code for CGI programs, but it could be useful in other
# contexts as well (Ex: site gneration packages).
#
# See the README.txt file for the real documentation, such as it is
#
# As a sidenote: if you are are using PageTemplate in your projects,
# or add features to your copy, we'd love to hear about it.
#
# Project home:
#   http://coolnamehere.com/products/pagetemplate/
#
# RubyForge url:
#   http://rubyforge.org/projects/pagetemplate/
#

############################################################

require 'ruby_ext'

require 'PageTemplate/command'

require 'PageTemplate/context_item'
require 'PageTemplate/context'

require 'PageTemplate/lexicon'
require 'PageTemplate/default_lexicon'

require 'PageTemplate/preprocessor'
require 'PageTemplate/default_preprocessor'

require 'PageTemplate/source'
require 'PageTemplate/file_source'
require 'PageTemplate/string_source'

require 'PageTemplate/parser'

require 'PageTemplate/template'

# PageTemplate is just the namespace for all of its real code, so as
# not to caues confusion or clashes with the programmer's code.
module PageTemplate
  VERSION = "2.2.3"

  # Passes arguments straight to Parser.new
  #
  # returns: a Parser object.
  def self.new(*args)
    Parser.new(*args)
  end
end

=begin

PageTemplate.rb is distributed under the MIT License, which is included
within this document.

The MIT License

Copyright (c) 2002-2005 Brian Wisti, Greg Millam

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Brian Wisti (brian@coolnamehere.com)
Greg Millam (walker@rubyforge.org)
=end
