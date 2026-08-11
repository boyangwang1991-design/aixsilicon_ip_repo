// =============================================================================
// File Name   : tlul_monitor.sv
// Description : TL-UL monitor - passively samples A/D channels
// =============================================================================

`ifndef TLUL_MONITOR__SV
`define TLUL_MONITOR__SV

class tlul_monitor extends uvm_monitor;

  tlul_monitor_cfg       cfg;
  virtual tlul_interface bus;

  uvm_analysis_port #(tlul_xaction) ap;

  `uvm_component_utils_begin(tlul_monitor)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "tlul_monitor", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task sample_stimulus_data();

endclass

function tlul_monitor::new(string name = "tlul_monitor", uvm_component parent = null);
  super.new(name, parent);
  ap = new("ap", this);
endfunction

function void tlul_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual tlul_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(tlul_monitor_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = tlul_monitor_cfg::type_id::create("cfg");
  end
endfunction

task tlul_monitor::run_phase(uvm_phase phase);
  wait(bus.rst_n === 1'b1);
  forever begin
    sample_stimulus_data();
  end
endtask

task tlul_monitor::sample_stimulus_data();
  tlul_xaction tr;

  @(bus.mon_cb);

  // Capture A channel request
  if (bus.mon_cb.a_valid === 1'b1 && bus.mon_cb.a_ready === 1'b1) begin
    tr = tlul_xaction::type_id::create("tr");
    tr.cmd  = (bus.mon_cb.a_opcode == TLUL_GET) ? TLUL_READ : TLUL_WRITE;
    tr.addr = bus.mon_cb.a_address;
    tr.strb = bus.mon_cb.a_mask;
    tr.data = bus.mon_cb.a_data;
    // Wait for D channel to capture read data
    @(bus.mon_cb);
    if (bus.mon_cb.d_valid === 1'b1) begin
      tr.resp = bus.mon_cb.d_error ? TLUL_RESP_ERROR : TLUL_RESP_OK;
      if (tr.cmd == TLUL_READ) begin
        tr.data = bus.mon_cb.d_data;
      end
    end
    ap.write(tr);
    if (cfg.enable_trace) begin
      `uvm_info(get_type_name(), tr.sprint(), UVM_MEDIUM)
    end
  end
endtask

`endif
