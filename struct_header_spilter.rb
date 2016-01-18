require 'fileutils'

def generate_header_dir_from(pub_dir,headername)
   dir = headername.split(/\./)
   target_dir = File.join(pub_dir, dir[0]);
   if(!File.exist?(target_dir))
       Dir::mkdir(target_dir)
   end
   target_dir
end

def generate_header_file_name_from(structname)
    header_file_name = String.new(structname)
    if(structname == "TPlmnId")
       header_file_name = "TMacPlmnId"
    end
    if(structname[1] != '_')
       header_file_name = header_file_name.insert(1,'_')
    end
    header_file_name = header_file_name.gsub(/[ET]_/,"ce_");
    header_file_name = header_file_name.gsub(/[a-z][A-Z]/){|s| s[0] + '_' + s[1]}
    header_file_name = header_file_name.gsub(/2/, "_to_")
    header_file_name = header_file_name.gsub(/4/, "_for_")
    header_file_name = header_file_name.gsub(/[A-Z][A-Z][a-z]/){|s| s[0] +'_' + s[1] + s[2]}
    header_file_name = header_file_name + ".h"
    header_file_name.downcase
end

class  Generate_header_file
        def initialize(target_head_dir,spliter_header_path)
            @spliter_header_path = spliter_header_path
            header_file_name = spliter_header_path.match(/[\w]+[\.]h/)
            @target_dir = generate_header_dir_from(target_head_dir, header_file_name[0])
            @test_struct_file_path = File.join(@target_dir,"/test_struct_name.h")
            @test_struct_include_path = File.join(@target_dir,"/test_include_file_list.h")
        end
private
        def is_type_def_begin(line)
            (line.include?"typedef")
        end

        def is_type_def_end(line)
             /[}][\s]*[TE]/.match(line)
        end

        def is_contain_struct(line)
            process_result = line.force_encoding("gb2312").lstrip
            (process_result[0] == 'T' ||process_result[0] == 'E') && (@is_write_able == 1) && @is_struct_type	
        end                               
        
        def get_struct_name(line)
            struct2 = /[TE][\w]+/.match(line.force_encoding("gb2312"))
            struct2[0]
        end

        def include_file_line_copy(source_path, header_file)
            lines = File.open(source_path, "r").readlines
            lines.each do |line|
                 header_file.puts line
            end 
        end
        
        def write_struct_name_line(header_file, line, structname)
            if((line.include?"enum") && (line.include?"typedef"))
               header_file.puts "typedef enum "+ structname
               if((line.include?"{"))
                 header_file.puts "{"
               end
            elsif((line.include?"struct") && (line.include?"typedef"))
                header_file.puts "typedef struct "+ structname
               if((line.include?"{"))
                 header_file.puts "{"
               end
            else
                header_file.puts line
            end
        end

        def struct_define_line_copy(source_path, header_file, structname)
            lines = File.open(source_path, "r").readlines
            lineindex = 0
            lines.each do |line|
                 if(lineindex == 0) 
                     write_struct_name_line(header_file, line, structname)
                 else
                     header_file.puts line
                 end
                 lineindex = lineindex + 1 
            end 
        end
        
        def is_struct_redefine(line)
            (!line.include?"enum") && (!line.include?"struct")
        end
        
        def do_generate_redefine(line) 
            node = line.split(/[\s\;]/)
            if(node[1][0] == 'T' or node[1][0] == 'E')
                include_struct_name = node[1]
                add_include_file_path(include_struct_name)
            end
            struct_name = node[2]
            do_generate_head_file(struct_name)
        end

        def do_generate_head_file(structname)
            write_file_path = generate_header_file_name_from(structname)
            @write_file.close
            @include_file.close
            header_file = File.new(File.join(@target_dir, write_file_path), "w")
            write_header_macro = write_file_path.upcase
            write_header_macro.gsub!(/\./, "_")
            header_file.puts "#ifndef " + write_header_macro
            header_file.puts "#define " + write_header_macro
            header_file.puts "\n"
            include_file_line_copy(@test_struct_include_path, header_file)
            header_file.puts "\n"
            struct_define_line_copy(@test_struct_file_path, header_file, structname)
            header_file.puts "\n"
            header_file.puts "#endif"
            File.delete(@test_struct_include_path)          
            File.delete(@test_struct_file_path)
        end

        def add_include_file_path(include_struct_name)
            include_file_path = generate_header_file_name_from(include_struct_name)
            @include_file.puts "#include \"" +include_file_path +"\""
        end
     
public
	def generate_for_struct()
	    lines = File.open(@spliter_header_path,"r").readlines
	    lines.each do |line|
                if (line.include?"#")
                    next
                end
		if is_type_def_begin(line)
		    @write_file = File.new(@test_struct_file_path,"w")
                    @include_file = File.new(@test_struct_include_path, "w")
                    if (is_struct_redefine(line))
                        @write_file.puts line
                        do_generate_redefine(line)
                        next
                    end
                    @is_write_able = 1
                    @is_struct_type = line.include?("struct")
                    if(@is_struct_type)
                        @include_file.puts "#include \"l0-infra/base/BaseTypes.h\""
                        @include_file.puts "#include \"ce_defs.h\""
                    end
		end

	        if(@is_write_able == 1)
                    write_line = line.force_encoding("gb2312").lstrip
                    if(write_line != "")
                        if((write_line.include?"{") || (write_line.include?"}"))
			    @write_file.puts write_line                        
			else
		            @write_file.puts "    "+write_line
                        end
                    end
                end
                
                if is_contain_struct(line)
                   include_struct_name = get_struct_name(line)
                   add_include_file_path(include_struct_name)
                end

		if is_type_def_end(line) 
		   structname = get_struct_name(line)
                   do_generate_head_file(structname)
                   @is_write_able = 0
		end
	    end
	end
end








 



