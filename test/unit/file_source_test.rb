require File.dirname(__FILE__)+'/test_helper'

require 'source'
require 'file_source'

include Papyrus

Expectations do
  
  # #initialize should symbolize keys of options hash 
  expect(:include_paths => nil) do
    source = FileSource.new('include_paths' => nil)
    source.send :instance_variable_get, "@options"
  end
  # #initialize should set @paths to :include_paths if that option is passed
  expect([ 'foo', 'bar', 'baz' ]) do
    source = FileSource.new(:include_paths => ['foo', 'bar', 'baz'])
    source.send :instance_variable_get, "@paths"
  end
  # #initialize should set @paths to [ :include_path ] if that option is passed
  expect([ 'foo' ]) do
    source = FileSource.new(:include_path => 'foo')
    source.send :instance_variable_get, "@paths"
  end
  # #initialize should set @paths to [ Dir.getwd, '/' ] by default
  expect([ Dir.getwd, '/' ]) do
    source = FileSource.new
    source.send :instance_variable_get, "@paths"
  end
  # #initialize should compact @paths
  expect([ 'foo', 'bar' ]) do
    source = FileSource.new(:include_paths => ['foo', nil, 'bar' ])
    source.send :instance_variable_get, "@paths"
  end
  # #initialize should initialize @cache
  expect Hash.new(nil) do
    source = FileSource.new
    source.send :instance_variable_get, "@cache"
  end
  # #initialize should initialize @mtime
  expect Hash.new(0) do
    source = FileSource.new
    source.send :instance_variable_get, "@mtime"
  end
  
  # #get when get_filename returns nil
  expect nil do
    source = FileSource.new
    source.stubs(:get_filename).returns(nil)
    source.get("foo.txt")
  end
  # #get when get_filename returns non-nil, but file not in @cache
  expect "some content" do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    IO.stubs(:read).returns("some content")
    source.get("foo.txt")
  end
  # #get when get_filename returns non-nil and file is in @cache, but cache is outdated
  expect "some content" do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    source.send :instance_variable_set, "@cache", { "/some/file" => nil }
    source.send :instance_variable_set, "@mtime", { "/some/file" => (Time.now - 38600).to_i }
    File.stubs(:mtime).returns(Time.now.to_i)
    IO.stubs(:read).returns("some content")
    source.get("foo.txt")
  end
  # #get when get_filename returns non-nil and template has been cached
  expect true do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    context = stub('context', :clear_cache => nil)
    source.send :instance_variable_set, "@cache", { "/some/file" => context }
    source.send :instance_variable_set, "@mtime", { "/some/file" => Time.now.to_i }
    File.stubs(:mtime).returns((Time.now - 38600).to_i)
    ret = source.get("foo.txt")
    context.equal?(ret)  # exact same object
  end
  # #get throws an error during the method
  expect "[ Unable to open file /some/file because of No such file or directory - /some/file ]" do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    #IO.stubs(:read).returns("some content")
    source.get("foo.txt")
  end
  
  # #cache should add an entry to @cache
  expect('/some/file' => "context") do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    source.cache('some file', "context")
    source.send :instance_variable_get, "@cache"
  end
  # #cache should add an entry to @mtime
  expect('/some/file' => Time.local(2008).to_i) do
    source = FileSource.new
    source.stubs(:get_filename).returns("/some/file")
    Time.stubs(:now).returns(Time.local(2008))
    source.cache('some file', "context")
    source.send :instance_variable_get, "@mtime"
  end
  
  # #get_filename if given file exists and filepath is an absolute path
  expect '/some/file' do
    source = FileSource.new
    File.stubs(:exists?).returns(true)
    File.stubs(:expand_path).returns('/some/file')
    source.get_filename('/some/file')
  end
  # #get_filename when given file is not absolute and doesn't exist
  expect nil do
    source = FileSource.new(:include_paths => %w(/some))
    File.stubs(:exists?).returns(false)
    File.stubs(:expand_path).returns('/some/file')
    source.get_filename('file')
  end
  # #get_filename when given file is not absolute and does exist
  expect '/some/file' do
    source = FileSource.new(:include_paths => %w(/some))
    File.stubs(:exists?).returns(true)
    File.stubs(:expand_path).returns('/some/file')
    source.get_filename('file')
  end
  # #get_filename should remove '../' from filepath
  expect '/some/file' do
    source = FileSource.new(:include_paths => %w(/some))
    File.stubs(:exists?).returns(true)
    File.stubs(:expand_path).returns('/some/file')
    source.get_filename('../file')
  end
  # #get_filename not make an effort to securitize absolute filepaths
  # when the directory where the file lives isn't in the include_paths
  expect '/some/file' do
    source = FileSource.new(:include_paths => %w(/different))
    File.stubs(:exists?).returns(true)
    File.stubs(:expand_path).returns('/some/file')
    source.get_filename('/some/file')
  end
  
end