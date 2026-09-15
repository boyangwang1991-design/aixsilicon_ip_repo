`ifndef APB_SECURE_DEMUX_ENV_PACKAGE__SV
`define APB_SECURE_DEMUX_ENV_PACKAGE__SV
package apb_secure_demux_env_package;
  import uvm_pkg::*;
  import apb_types_pkg::*;
  import apb_pkg::*;
  import apb_secure_demux_instance_pkg::*;
  `include "uvm_macros.svh"
  `include "apb_secure_demux_env_dec.sv"
  `include "apb_secure_demux_dut_cfg.sv"
  `include "apb_secure_demux_rm_cfg.sv"
  `include "apb_secure_demux_checker_cfg.sv"
  `include "apb_secure_demux_env_cfg.sv"
  `include "apb_secure_demux_rm.sv"
  `include "apb_secure_demux_fcov.sv"
  `include "apb_secure_demux_checker.sv"
  `include "apb_secure_demux_virtual_sequencer.sv"
  `include "apb_secure_demux_virtual_sequence.sv"
  `include "apb_secure_demux_env.sv"
endpackage

`endif // APB_SECURE_DEMUX_ENV_PACKAGE__SV
