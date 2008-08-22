module Papyrus
  # FileSource provides access to files within the 'include_paths'
  # argument.
  #
  # It attempts to be secure by not allowing any access outside of
  # the directories detailed within include_paths
  class FileSource < Source
    attr_accessor :paths

    # initialize looks for the following in the options Hash:
    #  * include_paths = a list of file paths
    #  * include_path  = a single file path string 
    #                    (kept for backwards compatibility)
    def initialize(options = {})
      @options  = options.symbolize_keys
      @paths = begin
        if    paths = @options[:include_paths] then paths
        elsif path  = @options[:include_path]  then [ path ]
        else                                     [ Dir.getwd, '/' ] end
      end.compact
      @cache = Hash.new(nil)
      @mtime = Hash.new(0)
    end

    
  end
end