
Dir.chdir("../../pub/")


search_dir = ["wrapper/cmacsharevar/",
              "wrapper/cmacstaticsinterface/",
              "wrapper/comminterface/",
              "wrapper/commmcmtype/",
              "wrapper/pub_lte_common_struct/",
              "wrapper/pub_lte_pdlm_bb_interface/",
              "wrapper/pub_lte_pulm_bb_interface/",
              "wrapper/pub_lte_rnlc_bb_interface/" ,
              "wrapper/pub_lte_rnlu_bb_interface/",
              "wrapper/pub_lte_rrm_bb_interface/"]

class   Updater
	def initialize(search_dir)
	    @search_dir = search_dir
	end

	def get_header_path_from_pub(filename)
	     header_path = filename
	     files = Dir.entries("./")
	     files.each do |file|
		 if (file == header_path)
		     return header_path
		 end
	     end
	     @search_dir.each do |dir|
		header_path = File.join(dir, filename)
		files = Dir.entries(dir)
		files.each do |file|
		    if (file == filename)
		        return header_path
		    end
		end
	     end
	     filename
	end

	def  update_include_file_path(file_path)
		lines = File.open(file_path,"r").readlines
		write_file = File.open(file_path,"w")
		lines.each do |line|
		    if((/ce_[\w]+[\.][h]/).match(line)) then
                       struct = /ce_[\w]+[\.][h]/.match(line)
	               include_file_name = struct[0]
                       include_file_path = get_header_path_from_pub(include_file_name)
                       line.gsub!(/ce_[\w]+[\.][h]/, include_file_path)
		    end
		    write_file.puts line		
	        end
	end

	def update_include_path()
	    @search_dir.each do |dir|
		files = Dir.entries(dir)
		files.each do |file|
                   if /[\w]+\.h/.match(file)
		      header_file_path = File.join(dir, file)
		      update_include_file_path(header_file_path)
                   end
		end   
	    end

	end
end

updater = Updater.new(search_dir)
updater.update_include_path







