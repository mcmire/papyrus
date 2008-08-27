module Papyrus
  # A ContextItem embodies a scope where values are stored. You can retrieve and set
  # these values inside the ContextItem by name. All ContextItems have a parent,
  # so if we're looking for a value and can't find it we have another place to try.
  # An 'object' (either a hash, or an actual object) may also be bound to the
  # ContextItem which is a bit like using the JavaScript 'with' keyword.
  module ContextItem
    attr_accessor :object
    attr_writer :vars
    
    # Returns the hash of values stored for this context, instantiating the hash
    # if necessary.
    def vars
      @vars ||= {}
    end

    # Clears the hash of variables, and the associated object.
    def reset_context
      @vars = {}
      @object = nil
    end

    # Stores the given value in the context by the given key.
    def set(key, value)
      vars[key.to_s] = value
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
    
    
    # Searches for the given key in the values for this context or an ancestor context.
    # Returns the value if it's found, or nil.
    #
    # If the key is a dot-separated set of words, we break the key into parts.
    # Starting with the first word, we resolve it, then use the resulting value to
    # resolve the second word (it can either refer to a hash key, array index, or
    # method of the value). We then use the value we get from that to resolve the next
    # word, continuing until we've resolved all the words. The final value is returned. 
    #
    # If the key starts with a number, then it is just returned, since a variable
    # cannot start with a number.
    def get(key)
      key = key.to_s
      return key if key =~ /^\d/
      
      first, rest = key.split(".", 2)
      
      value = get_primary_part(first, key)
      return value unless rest
      
      key_parts = [first]
      value_so_far = value
      rest.split(".").each do |k|
        key_parts << k
        key_so_far = key_parts.join(".")
        value_so_far = get_secondary_part(key_so_far, k, value_so_far)
      end
      value_so_far
    end
    alias_method :[], :get

    # Removes an entry from the Context
    def delete(key)
      vars.delete(key)
    end

    # Returns the parser of this context's parent, or @parser if this is a Template.
    def parser
      parent ? parent.parser : @parser
    end

    # A convenience method to test whether the given variable (or value) has a true
    # value. Returns false if the given variable is not found in the context or has
    # a false value.
    def true?(var_or_value)
      !!get(var_or_value)
    end
    
  private
    # Resolves the given word by trying:
    # - vars[ key ]
    # - vars[ key.to_sym ]
    # - object[ key ]
    # - object.send(key)
    # - parent.get(key)
    def get_primary_part(key, whole_key)
      if vars.has_key?(key)
        vars[key]
      elsif vars.has_key?(key.to_sym)
        vars[key.to_sym]
      elsif !object && parent
        parent_get(whole_key)
      elsif object.respond_to?(:has_key?)
        if object.has_key?(key)
          #vars[key] = object[key]
          object[key]
        elsif parent
          parent_get(whole_key)
        end
      elsif object.respond_to?(sym = key.to_sym)
        #vars[key] = object.send(sym)
        object.send(sym)
      #elsif key == '__ITEM__'
      #  object
      elsif parent
        parent_get(whole_key)
      end
    end
    
    # Resolves the given word by trying:
    # - vars[ key_so_far ]
    # - value_so_far[ key ]
    # - value_so_far[ key.to_i ]
    # - value_so_far.send(key)
    # where +key_so_far+ is the word or dot-separated set of words we've resolved so
    # far, and +value_so_far+ is the value it resolved to.
    def get_secondary_part(key_so_far, key, value_so_far)
      if vars.has_key?(key_so_far)
        vars[key_so_far]
      elsif value_so_far.respond_to?(:has_key?) # Hash
        value_so_far[key]
      elsif value_so_far.respond_to?(:[]) && key =~ /^\d+$/ # Array
        value_so_far[key.to_i]
      elsif value_so_far.respond_to?(sym = key.to_sym) # Just a method
        value_so_far.send(sym)
      end
    end
    
    # Hack to get around the fact that BlockCommand#get overrides get to use
    # active_block.get. In that case  we need to call the original get, otherwise we
    # may very well have an infinite loop.
    def parent_get(key)
      parent.is_a?(BlockCommand) ? parent._get(key) : parent.get(key)
    end
  end
end