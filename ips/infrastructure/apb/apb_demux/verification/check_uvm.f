// check_uvm.f - APB Demux VCS elaboration filelist
-sverilog
-ntb_opts uvm-1.2
+incdir+../env
+incdir+../tc
+incdir+../th
../../rtl/apb_demux_top.sv
../env/apb_demux_env_pkg.sv
../tc/tc_base.sv
../tc/tc_sanity.sv
../tc/tc_address_decode.sv
../tc/tc_psel_onehot.sv
../tc/tc_wait_states.sv
../tc/tc_pslverr.sv
../tc/tc_decode_miss.sv
../tc/tc_remap.sv
../tc/tc_timeout.sv
../tc/tc_output_register.sv
../tc/tc_reset.sv
../tc/tc_num_slaves_sweep.sv
../tc/tc_apb4.sv
../tc/tc_assertions.sv
../th/tb_top.sv
