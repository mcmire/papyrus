class PageTemplate
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
      @values ||= {}
      @values[key] = value
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
    # If +val+ is a dot-separated list of words, then 'key' is the
    # first part of it.  The remainder of the words are sent to key
    # (and further results) to premit accessing attributes of objects.
    def get(val,clean_rescue=true)
      args = parser.args
      @values ||= {}
      @object ||= nil

      clean_rescue = !args['raise_on_error'] if clean_rescue

      val.gsub!(/[#{Regexp.escape(parser.method_separators)}]/,'.')

      key, rest = val.split(/\./, 2)

      value = case
      when @values.has_key?(key)
        @values[key]
      when @values.has_key?(key.to_sym)
        @values[key.to_sym]
      when !@object
        if @parent
          @parent.get(val)
        else
          nil
        end
      when @object.respond_to?(:has_key?)
        if @object.has_key?(key)
          @values[key] = @object[key]
        else
          return @parent.get(val) if @parent
          nil
        end
      when @object.respond_to?(sym = key.to_sym)
        @values[key] = @object.send(sym)
      when key == '__ITEM__'
        @object
      when @parent
        return @parent.get(val)
      else
        nil
      end

      if rest
        names = [key]
        rest.split(/\./).each do |i|
          names << i
          name = names.join('.')
          begin
            value = if @values.has_key?(name)
              @values[name]
            else
              @values[name] = value = case
              when @values.has_key?(name)
                @values[name]
              when value.respond_to?(:has_key?) # Hash
                value[i]
              when value.respond_to?(:[]) && i =~ /^\d+$/ # Array
                value[i.to_i]
              when value.respond_to?(i) # Just a method
                value.send(i)
              else
                nil
              end
            end
          rescue NoMethodError => er
            return nil
          end
        end
      end
      value
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
      @values.delete(key)
    end

    # parser: most context objects won't be a parser, but pass this
    # query up to the parser object.
    def parser
      if @parent
        @parent.parser
      else
        Parser.recent_parser
      end
    end

    # A convenience method to test whether a variable has a true
    # value. Returns nil if +flag+ is not found in the context, 
    # or +flag+ has a nil value attached to it.
    def true?(flag)
      args = parser.args
      val = get(flag,false)
      case
      when ! val
        false
      when args['empty_is_true']
        true
      when val.respond_to?(:empty?)
        ! val.empty?
      else
        true
      end
    rescue Exception => er
      false
    end
  end
end