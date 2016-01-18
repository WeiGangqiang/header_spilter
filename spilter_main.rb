require './header_file_pre_complie.rb'
require './struct_header_spilter.rb'

spliter_header_paths = ["./pub/include/pub_lte_rnlc_bb_interface.h",
                   "./pub/include/pub_lte_common_struct.h" ,
                   "./pub/include/pub_lte_pdlm_bb_interface.h",
                   "./pub/include/pub_lte_pulm_bb_interface.h",
                   "./pub/include/pub_lte_rnlu_bb_interface.h",
                   "./pub/include/pub_lte_rrm_bb_interface.h",
                   "./cmac/common/include/cmacsharevar.h",
                   "./cmac/common/include/comminterface.h",
                   "./cmac/mcm/common/include/commmcmtype.h",
                   "./cmac/pub/include/cmacstaticsinterface.h"]
                   #"./cmac/common/include/cmactypedef.h"]
                   #"./pub/include/pub_trigger.h"]

target_dir = "./cmac/ce/pub/wrapper/"

defs = "-D_PRODUCT_TYPE=10 \
         -D_PRODUCT_LTE_TDD=10 \
         -D_CHIP_Freescale_E500MC \
        -DTI_C66X \
        -DMNT_DISABLE_HOTPATCH \
        -DOSS_ASYN_START \
        -DGDB_ENABLE \
        -DFSL_E500MC \
        -D_BT_3G_BPL1 \
        -DOSS_DEBUG_LEVEL_O0 \
        -DVOS_LWOS \
        -D_LOGIC_BSTRQA=1  \
        -D_LOGIC_BPLB=2  \
        -D_LOGIC_BOARD=_LOGIC_BPLB "

gcc= "colorgcc -g  #{defs} -E "

Dir.chdir("../../../../")

spliter_header_paths.each do |header_path|
   preComplie = PreComplie.new(header_path, target_dir, gcc)
   preComplie.complie()
   compile_path = preComplie.get_head_file_name()
   generate_header_file = Generate_header_file.new(target_dir, compile_path)
   generate_header_file.generate_for_struct()
end


