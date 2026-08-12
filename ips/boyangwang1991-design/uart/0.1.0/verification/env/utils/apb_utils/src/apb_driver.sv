// =============================================================================
// File Name   : apb_driver.sv
// Description : APB4 master driver (APB4 two-phase protocol)
// =============================================================================

`ifndef APB_DRIVER__SV
`define APB_DRIVER__SV

class apb_driver extends uvm_driver #(apb_xaction);

  apb_driver_cfg        cfg;
  virtual apb_interface bus;

  `uvm_component_utils_begin(apb_driver)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "apb_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task reset();
  extern virtual task send_stimulus_data(apb_xaction tr);
  extern virtual function void drv_random();

endclass

function apb_driver::new(string name = "apb_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual apb_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(apb_driver_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = apb_driver_cfg::type_id::create("cfg");
  end
endfunction

task apb_driver::run_phase(uvm_phase phase);
  apb_xaction tr;
  reset();
  forever begin
    seq_item_port.get_next_item(tr);
    drv_random();
    send_stimulus_data(tr);
    seq_item_port.item_done();
  end
endtask

task apb_driver::reset();
  bus.drv_cb.psel    <= 1'b0;
  bus.drv_cb.penable <= 1'b0;
  bus.drv_cb.pwrite  <= 1'b0;
  bus.drv_cb.paddr   <= '0;
  bus.drv_cb.pwdata  <= '0;
  bus.drv_cb.pstrb   <= '0;
  wait(bus.rst_n === 1'b1);
endtask

task apb_driver::send_stimulus_data(apb_xaction tr);
  repeat (cfg.idle_cycles) @(bus.drv_cb);

  // Setup phase: PSEL=1, PENABLE=0
  bus.drv_cb.psel    <= 1'b1;
  bus.drv_cb.penable <= 1'b0;
  bus.drv_cb.pwrite  <= (tr.cmd == APB_WRITE);
  bus.drv_cb.paddr   <= tr.addr;
  bus.drv_cb.pwdata  <= tr.data;
  bus.drv_cb.pstrb   <= tr.strb;
  @(bus.drv_cb);

  // Access phase: PENABLE=1, wait PREADY
  bus.drv_cb.penable <= 1'b1;
  do begin
    @(bus.drv_cb);
  end while (bus.drv_cb.pready !== 1'b1);

  // Capture response
  tr.resp = bus.drv_cb.pslverr ? APB_RESP_ERROR : APB_RESP_OK;
  if (tr.cmd == APB_READ) begin
    tr.data = bus.drv_cb.prdata;
  end

  // Deassert PSEL (end transfer)
  bus.drv_cb.psel    <= 1'b0;
  bus.drv_cb.penable <= 1'b0;
  bus.drv_cb.pwrite  <= 1'b0;
  bus.drv_cb.paddr   <= '0;
  bus.drv_cb.pwdata  <= '0;
  bus.drv_cb.pstrb   <= '0;
  @(bus.drv_cb);

  repeat (cfg.idle_cycles) @(bus.drv_cb);
endtask

function void apb_driver::drv_random();
endfunction

`endif
