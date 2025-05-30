# The synthesis options

set_device GW2A-LV18PG256C8/I7 -name GW2A-18C -device_version C
set_option -synthesis_tool gowinsynthesis
set_option -output_base_name fpga_project
set_option -top_module board_specific_top
set_option -verilog_std sysv2017
set_option -use_sspi_as_gpio 1
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1
# set_option -cmser_mode auto
