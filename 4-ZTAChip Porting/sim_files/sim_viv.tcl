create_project zta_sim1 . 
read_verilog -sv main_simv.sv
read_verilog afifo2.v
read_verilog afifo.v
read_verilog -sv axi_read.sv
read_verilog -sv axiwrite.sv
read_verilog fifo.v
read_verilog riscv.v
read_verilog memory_dpdistram.v
read_verilog DPRAM_BE.v
read_verilog memory_sdpram_be.v
read_verilog SHIFT.v
read_verilog DPRAM_DUAL_CLOCK.v
read_verilog memory_sdpram.v
read_verilog DPRAM.v
read_verilog memory_spram_be.v
read_verilog CCD_SYNC.v
read_verilog memory_spram.v
read_verilog SPRAM_BE.v
read_verilog cdc_array_single.v
read_verilog SPRAM.v
read_verilog SYNC_LATCH.v
read_verilog ram.v
read_verilog camera_emu.v
read_verilog soc.v
read_verilog -sv mem64v.sv
#/////--------------------------------------------------//////#
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./image_data.text
set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ./mem_trial.mem
set_property top main [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation
open_vcd pip1_sim.vcd
log_vcd [get_objects /main_simv/*]
run 6215906558ps
close_vcd
close_sim
close_project
exit

