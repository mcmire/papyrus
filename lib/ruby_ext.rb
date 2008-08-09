require 'pp'

class String
  def constantize
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ self
      raise NameError, "#{self.inspect} is not a valid constant name!"
    end
    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.first + self.camelize[1..-1]
    end
  end
end

class Object
  def blank?
    (respond_to?(:empty?) && empty?) || nil?
  end
  def pretty_inspect
    PP.pp(self, '')
  end
end

module Enumerable
  def map_with_index
    result = []
    self.each_with_index do |elt, idx|
      result << yield(elt, idx)
    end
    result
  end
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