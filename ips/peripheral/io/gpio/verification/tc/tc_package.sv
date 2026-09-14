package tc_package;
 import uvm_pkg::*;import apb_package::*;import gpio_env_package::*;
 `include "uvm_macros.svh"
 `include "tc_base.sv"
 `include "tc_gpio_apb.sv"
 `include "tc_gpio_config.sv"
 `include "tc_gpio_output.sv"
 `include "tc_gpio_input.sv"
 `include "tc_gpio_filter.sv"
 `include "tc_gpio_irq.sv"
 `include "tc_gpio_security.sv"
 `include "tc_gpio_lowpower.sv"
 `include "tc_gpio_aon.sv"
 `include "tc_gpio_capture.sv"
 `include "tc_gpio_fifo.sv"
 `include "tc_gpio_diag.sv"
 `include "tc_gpio_parity.sv"
 `include "tc_gpio_reset.sv"
endpackage
