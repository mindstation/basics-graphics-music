create_clock -period "50.0 MHz" [get_ports CLOCK_50]

derive_clock_uncertainty

set_false_path -from [get_ports {KEY[*]}]   -to [all_clocks]
set_false_path -from [get_ports {SW[*]}]    -to [all_clocks]
set_false_path -from UART_RTS               -to [all_clocks]
set_false_path -from UART_RXD               -to [all_clocks]
set_false_path -from [get_ports {GPIO[*]}]  -to [all_clocks]

set_false_path -from * -to [get_ports {LEDR[*]}]
set_false_path -from * -to [get_ports {LEDG[*]}]
set_false_path -from * -to [get_ports {HEX*}]
set_false_path -from * -to [get_ports {VGA_*}]
set_false_path -from * -to UART_CTS
set_false_path -from * -to UART_TXD
set_false_path -from * -to [get_ports {GPIO[*]}]

#///////////////////////////////////////////////////
#            SDRAM
#///////////////////////////////////////////////////
# FPGA output to SDRAM inputs delay (addr, ba, dq, dqm, ras_n, cas_n, we_n IS42S16320D-7TL have same hold and setup time)
# Tds, Tas
set sdram_input_setup 1.5
# Tdh, Tah
set sdram_input_hold -0.8
set_output_delay -clock sdram_clk -max $sdram_input_setup [get_ports DRAM_*]
set_output_delay -clock sdram_clk -min $sdram_input_hold [get_ports DRAM_*]

# SDRAM IS42S16320D-7TL output to FPGA inputs delay
set sdram_Tac2 6
set sdram_Toh2 2.7
set_input_delay -clock sdram_clk -max $sdram_Tac2 [get_ports DRAM_DQ[*]]
set_input_delay -clock sdram_clk -min $sdram_Toh2 [get_ports DRAM_DQ[*]]
