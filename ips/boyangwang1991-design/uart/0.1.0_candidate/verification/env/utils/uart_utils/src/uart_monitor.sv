// =============================================================================
// File Name   : uart_monitor.sv
// Description : UART monitor - samples serial tx line and reconstructs frames
// =============================================================================

`ifndef UART_MONITOR__SV
`define UART_MONITOR__SV

class uart_monitor extends uvm_monitor;

  uart_monitor_cfg       cfg;
  virtual uart_interface bus;

  uvm_analysis_port #(uart_xaction) ap;

  `uvm_component_utils_begin(uart_monitor)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "uart_monitor", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task sample_stimulus_data();

endclass

function uart_monitor::new(string name = "uart_monitor", uvm_component parent = null);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

function void uart_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual uart_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(uart_monitor_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = uart_monitor_cfg::type_id::create("cfg");
  end
endfunction

task uart_monitor::run_phase(uvm_phase phase);
  wait(bus.rst_n === 1'b1);
  forever begin
    sample_stimulus_data();
  end
endtask

// Simplified monitor: waits for start bit (falling edge) on tx, then samples
// center of each bit using a fixed 16x oversample assumption.
task uart_monitor::sample_stimulus_data();
  uart_xaction tr;
  int unsigned half_period;

  // Wait for tx idle high, then falling edge (start bit)
  do begin
    @(bus.mon_cb);
  end while (bus.mon_cb.tx !== 1'b1);
  do begin
    @(bus.mon_cb);
  end while (bus.mon_cb.tx !== 1'b0);

  // Start bit sampled - assume baud_div from cfg (simplified fixed divider)
  half_period = cfg.baud_div / 2;
  if (half_period < 1) half_period = 1;

  tr = uart_xaction::type_id::create("tr");
  tr.data = '0;

  // Skip to center of start bit
  repeat (half_period) @(bus.mon_cb);

  // Sample 8 data bits LSB first at bit centers
  for (int i = 0; i < 8; i++) begin
    repeat (cfg.baud_div) @(bus.mon_cb);
    tr.data[i] = bus.mon_cb.tx;
  end

  ap.write(tr);
  if (cfg.enable_trace) begin
    `uvm_info(get_type_name(), tr.sprint(), UVM_MEDIUM)
  end
endtask

`endif
