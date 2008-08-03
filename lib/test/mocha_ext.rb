module Mocha
  class AnyInstanceMethod < ClassMethod
    def define_new_method
      stubbee.class_eval "def #{method}(*args, &block); #{stubbee}.any_instance.mocha.method_missing(:#{method}, *args, &block); end"
    end
  end
end