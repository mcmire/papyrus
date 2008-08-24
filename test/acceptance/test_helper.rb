root = File.dirname(__FILE__)+'/../..'
$LOAD_PATH.unshift "#{root}/lib", "#{root}/lib/papyrus", "#{root}/lib/test"
Dir["#{root}/lib/test/**"].each do |dir|
  $LOAD_PATH.unshift(File.directory?(lib = "#{dir}/lib") ? lib : dir)
end

require 'expectations'
require 'mocha_ext'

class Object
  def expectations_equal_to(other)
    self.equal?(other) || self === other || self == other
  end
end

# provides a local variable scope (can't just use begin..end)
def locally; yield; end

require 'ruby_ext'