require 'fileutils'

class PreComplie
    
    def initialize(header_path, target_dir, gcc)
        @gcc = gcc
        @header_path = header_path
        @header_file_name = get_header_file_name()
        @header_cpp_name = @header_file_name.gsub(/\.h/, ".cpp")
        @make_cpp_path = File.join(target_dir, @header_cpp_name)
        @make_i_path = File.join(target_dir, @header_file_name)
    end

    def complie()
        generate_make_cpp()
        remove_old_file(@make_i_path)
        run_gcc()
        remove_old_file(@make_cpp_path)
    end
    
    def get_head_file_name()
        @make_i_path
    end

private

    def run_gcc()
        gccCmd = @gcc + @make_cpp_path + " > " + @make_i_path
        run_cmd(gccCmd)
    end

    def run_cmd(cmdLine)
        #puts "execute:" + cmdLine
        system cmdLine
    end

    def get_header_file_name()
        struct = @header_path.match(/[\w]+[\.]h/)
        struct[0]
    end
    
    def remove_old_file(file_path)
        if(File.exist?(file_path))
           File.delete(file_path)
        end
    end

    def generate_make_cpp()
        remove_old_file(@make_cpp_path)
        make_cpp = File.open(@make_cpp_path, "w")
        lines = File.open(@header_path,"r").readlines
        lines.each do |line|
             if ((line.include?"#include") || (line.include?"#define")) 
                 next
             end
             make_cpp.puts line
        end
        make_cpp.close
   end
end












