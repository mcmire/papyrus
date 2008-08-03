module PageTemplate
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

    # Return the contents of the file +name+, which must be within the
    # include_paths.
    def get(name)
      return unless fn = get_filename(name)
      if @cache.has_key?(fn) && @mtime[fn] > File.mtime(fn).to_i
        template = @cache[fn]
        template.clear_cache
        template
      else
        IO.read(fn)
      end
    rescue Exception => er
      return "[ Unable to open file #{fn} because of #{er.message} ]"
    end
    
    # Stores the template with its filename in a hash, and the modified time
    # of the template file in another hash.
    def cache(name, template)
      fn = get_filename(name)
      @cache[fn] = template.dup
      @mtime[fn] = Time.now.to_i
    end
    
    def get_filename(file)
      # Check for absolute filepaths
      return file if File.exists?(file) && file == File.expand_path(file)
      file = file.gsub(/\.\.\//,'') 
      @paths.each do |path|
        fn = File.join(path,file)
        fn.untaint
        return fn if File.exists?(fn)
      end
      return nil
    end
  end
end