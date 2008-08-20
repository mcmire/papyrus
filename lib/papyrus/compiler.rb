require 'zlib'

module Papyrus
  class Compiler

    class << self
      def compile(name)
        new(name).compile
      end
    end
    
    attr_reader :source_file
    
    def initialize(name)
      @source_file = get_source_path(name)
      raise "Template '#{name}' not found!" unless @source_file
    end
    
    def get_source_path(name)
      name = name.gsub("../", "")
      for path in Papyrus.source_template_dirs
        file = File.join(path, name)
        file.untaint
        return File.expand_path(file) if File.exists?(file)
      end
      return nil
    end
    
    def compiled_file
      @compiled_file ||= File.join(Papyrus.compiled_template_dir, File.basename(source_file))
    end
    
    def source_mtime
      File.mtime(source_file)
    end
    
    def compiled_mtime
      File.mtime(compiled_file)
    end

    # Retrieves the content of the given file, if it exists, possibly passing
    # it through the tokenizer/compiler.
    def compile
      compile_source_template if File.exists?(compiled_file) && source_mtime <= compiled_mtime
        get_compiled_template
      else
        
      end
    end
    
    def get_compiled_template
      data = File.open(compiled_file) {|f| f.read }
      template = Marshal.load(Zlib::Inflate.inflate(data))
      template.clear_values
      template
    end
    
    def compile_source_template
      content = File.open(source_file) {|f| f.read }
      template = Parser.parse(content)
      data = Zlib::Deflate.deflate(Marshal.dump(template))
      File.open(compiled_file, "w") {|f| f.write(data) }
      template
    end
 
  end
end