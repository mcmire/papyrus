class PageTemplate
  # FileSource provides access to files within the 'include_paths'
  # argument.
  #
  # It attempts to be secure by not allowing any access outside of
  # The directories detailed within include_paths
  class FileSource < Source
    attr_accessor :paths

    # initialize looks for the following in the args Hash:
    #  * include_paths = a list of file paths
    #  * include_path  = a single file path string 
    #                    (kept for backwards compatibility)
    def initialize(args = {})
      @args  = args
      if @args['include_paths']
        @paths = @args['include_paths']
      elsif @args['include_path']
        @paths = [ @args['include_path'] ]
      else
        @paths = [Dir.getwd,'/']
      end
      @paths = @paths.compact
      @cache = Hash.new(nil)
      @mtime = Hash.new(0)
    end

    # Return the contents of the file +name+, which must be within the
    # include_paths.
    def get(name)
      fn = get_filename(name)
      begin
        case
      when fn.nil?
        nil
      when @cache.has_key?(fn) && (@mtime[fn] > File.mtime(fn).to_i)
        cmds = @cache[fn]
        cmds.clear_cache
        cmds
      else
        IO.read(fn)
      end
      rescue Exception => er
        return "[ Unable to open file #{fn} because of #{er.message} ]"
      end
    end
    def cache(name,cmds)
      fn = get_filename(name)
      @cache[fn] = cmds.dup
      @mtime[fn] = Time.now.to_i
    end
    def get_filename(file)
      # Check for absolute filepaths
      if file == File.expand_path(file)
        if File.exists?(file)
          return file
        end
      end
      file = file.gsub(/\.\.\//,'') 
      @paths.each do |path|
        fn = File.join(path,file)
        fn.untaint
        if File.exists?(fn)
          return fn
        end
      end
      return nil
    end
  end
end