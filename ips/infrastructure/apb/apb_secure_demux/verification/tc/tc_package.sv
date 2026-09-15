`ifndef TC_PACKAGE__SV
`define TC_PACKAGE__SV
package tc_package;
  import uvm_pkg::*;
  import apb_pkg::*;
  import apb_types_pkg::*;
  import apb_secure_demux_instance_pkg::*;
  import apb_secure_demux_env_package::*;
  `include "uvm_macros.svh"
  `include "tc_base.sv"
  `include "tc_apb_secure_demux_acl_smoke.sv"
  `include "tc_apb_secure_demux_csr_smoke.sv"
  `include "tc_apb_secure_demux_apb_smoke.sv"
  `include "tc_apb_secure_demux_reset.sv"
  `include "tc_apb_secure_demux_acl.sv"
  `include "tc_apb_secure_demux_csr.sv"
  `include "tc_apb_secure_demux_dfx.sv"
  `include "tc_apb_secure_demux_error.sv"
  `include "tc_apb_secure_demux_irq.sv"
  `include "tc_apb_secure_demux_log.sv"
  `include "tc_apb_secure_demux_param.sv"
  `include "tc_apb_secure_demux_update.sv"
  `include "tc_apb_secure_demux_apb.sv"
  `include "tc_apb_secure_demux_decode.sv"
  `include "tc_apb_secure_demux_integrity.sv"
  `include "tc_apb_secure_demux_interface.sv"
  `include "tc_apb_secure_demux_random_stress.sv"
endpackage

`endif // TC_PACKAGE__SV
