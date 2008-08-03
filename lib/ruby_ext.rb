class String
  def constantize(camel_cased_word)
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end
    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
end

class Object
  def blank?
    (respond_to?(:empty?) && empty?) || nil?
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