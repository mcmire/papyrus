module PageTemplate
  # A Context object consists of three things:
  #
  # parent: A parent object to get a value from if the context
  # does not 'know' a value.
  #
  # object: An object is a hash or list that contains the values that
  # this context will refer to. It may also be an object, in which
  # case, its methods are treated as a hash, with respond_to? and
  # send()
  #
  # Cache: A cache ensures that a method on an object will only be
  # called once.
  module ContextItem
    attr_accessor :parent, :object

    # Clears the cache
    def clear
      @values = Hash.new
    end
    alias_method :clear_cache, :clear

    # Saves a variable +key+ as the string +value+ in the global 
    # context.
    def set(key, value)
      values[key.to_s] = value
    end
    alias_method :[]=, :set

    # Returns the first value found for +key+ in the nested contexts.
    # Returns nil if no value is found.
    #
    # Values are checked for in this order through each level of context:
    # 
    # * level.key
    # * level.key()
    # * level[key]
    #
    # If a value is not found in any of the nested contexts, get()
    # searches for the key in the global context.
    #
    # If +key+ is a dot-separated list of words, then 'first' is the
    # first part of it.  The remainder of the words are sent to key
    # (and further results) to permit accessing attributes of objects.
    def get(key, clean_rescue=false)
      key = key.to_s
      options = parser.options
      clean_rescue = !options[:raise_on_error] if clean_rescue
      regexp = parser.method_separator_regexp
      key.gsub!(regexp, ".")

      first, rest = key.split(".", 2)
      
      value = get_primary_part(first, key)
      return value.first if value.is_a?(Array) && value.last === true
      return value unless rest
      
      key_parts = [first]
      value_so_far = value
      rest.split(regexp).each do |k|
        key_parts << k
        key_so_far = key_parts.join(".")
        value_so_far = get_secondary_part(key_so_far, k, value_so_far)
      end
      value_so_far
    rescue Exception => e
      if clean_rescue
        "[ Error: #{e.message} ]"
      else
        raise e
      end
    end
    alias_method :[], :get

    # Removes an entry from the Context
    def delete(key)
      values.delete(key)
    end

    # parser: most context objects won't be a parser, but pass this
    # query up to the parser object.
    def parser
      (parent && parent.parser) || Parser.recent_parser
    end

    # A convenience method to test whether a variable has a true
    # value. Returns nil if +flag+ is not found in the context, 
    # or +flag+ has a nil value attached to it.
    # TODO: Clean up?
    def true?(flag)
      options = parser.options
      val = get(flag, false)
      case
      when !val
        false
      when options[:empty_is_true]
        true
      when val.respond_to?(:empty?)
        ! val.empty?
      else
        true
      end
    rescue Exception => er
      false
    end
    
  private
    attr_writer :values
    def values
      @values ||= {}
    end
    
    attr_reader :parent
    
    def get_primary_part(key, whole_key)
      if values.has_key?(key)
        values[key]
      #elsif values.has_key?(key.to_sym)
      #  values[key.to_sym]
      elsif !object && parent
        parent.get(whole_key)
      elsif object.respond_to?(:has_key?)
        if object.has_key?(key)
          values[key] = object[key]
        elsif parent
          [parent.get(whole_key), true]
        end
      elsif object.respond_to?(sym = key.to_sym)
        values[key] = object.send(sym)
      elsif key == '__ITEM__'
        object
      elsif parent
        [parent.get(whole_key), true]
      end
    end
    
    def get_secondary_part(key_so_far, key, value_so_far)
      begin
        values[key_so_far] =
          if values.has_key?(key_so_far)
            values[key_so_far]
          elsif value_so_far.respond_to?(:has_key?) # Hash
            value_so_far[key]
          elsif value_so_far.respond_to?(:[]) && key =~ /^\d+$/ # Array
            value_so_far[key.to_i]
          elsif value_so_far.respond_to?(sym = key.to_sym) # Just a method
            value_so_far.send(sym)
          end
      rescue NoMethodError
        nil
      end
    end
  end
end