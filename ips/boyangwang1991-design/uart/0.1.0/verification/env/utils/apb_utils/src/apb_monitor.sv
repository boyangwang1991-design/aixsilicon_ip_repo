// =============================================================================
// File Name   : apb_monitor.sv
// Description : APB4 monitor - passively samples APB bus
// =============================================================================

`ifndef APB_MONITOR__SV
`define APB_MONITOR__SV

class apb_monitor extends uvm_monitor;

  apb_monitor_cfg       cfg;
  virtual apb_interface bus;

  uvm_analysis_port #(apb_xaction) ap;

  `uvm_component_utils_begin(apb_monitor)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "apb_monitor", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task sample_stimulus_data();

endclass

function apb_monitor::new(string name = "apb_monitor", uvm_component parent = null);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

function void apb_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual apb_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(apb_monitor_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = apb_monitor_cfg::type_id::create("cfg");
  end
endfunction

task apb_monitor::run_phase(uvm_phase phase);
  wait(bus.rst_n === 1'b1);
  forever begin
    sample_stimulus_data();
  end
endtask

task apb_monitor::sample_stimulus_data();
  apb_xaction tr;

  // Wait for PSEL && !PENABLE (setup phase)
  do begin
    @(bus.mon_cb);
  end while (!(bus.mon_cb.psel === 1'b1 && bus.mon_cb.penable === 1'b0));

  // Capture request at setup edge
  tr = apb_xaction::type_id::create("tr");
  tr.cmd  = bus.mon_cb.pwrite ? APB_WRITE : APB_READ;
  tr.addr = bus.mon_cb.paddr;
  tr.data = bus.mon_cb.pwdata;
  tr.strb = bus.mon_cb.pstrb;

  // Wait for access phase + pready
  do begin
    @(bus.mon_cb);
  end while (!(bus.mon_cb.penable === 1'b1 && bus.mon_cb.pready === 1'b1));

  // Capture read data at access edge
  if (tr.cmd == APB_READ) begin
    tr.data = bus.mon_cb.prdata;
  end
  tr.resp = bus.mon_cb.pslverr ? APB_RESP_ERROR : APB_RESP_OK;

  ap.write(tr);
  if (cfg.enable_trace) begin
    `uvm_info(get_type_name(), tr.sprint(), UVM_MEDIUM)
  end
endtask

`endif
