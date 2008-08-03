root = File.dirname(__FILE__)+'/../..'
$LOAD_PATH.unshift "#{root}/lib", "#{root}/lib/PageTemplate", "#{root}/lib/test"
Dir["#{root}/lib/test/**"].each do |dir|
  $LOAD_PATH.unshift(File.directory?(lib = "#{dir}/lib") ? lib : dir)
end

require 'spec'

require 'PageTemplate'