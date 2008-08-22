require 'pp'

class String
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.first + self.camelize[1..-1]
    end
  end
end

class Object
  # Copied from Rails
  def blank?
    (respond_to?(:empty?) && empty?) || nil?
  end
  def pretty_inspect
    PP.pp(self, '')
  end
end

module Enumerable
  def inject_with_index(injected)
    each_with_index {|obj, index| injected = yield(injected, obj, index) }
    injected
  end
end

class Hash
  def symbolize_keys
    inject({}) {|hash,(k,v)| hash[k.to_sym] = v; hash }
  end
  def symbolize_keys!
    replace(symbolize_keys)
  end
end

class File
  def self.read(file)
    File.open(file) {|f| f.read }
  end
  def self.write(file, content)
    File.open(file, "w") {|f| f.write(content) }
  end
end
    