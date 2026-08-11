// =============================================================================
// File Name   : tlul_driver.sv
// Description : TL-UL master driver
//               Drives A channel request, waits D channel response.
// =============================================================================

`ifndef TLUL_DRIVER__SV
`define TLUL_DRIVER__SV

class tlul_driver extends uvm_driver #(tlul_xaction);

  tlul_driver_cfg        cfg;
  virtual tlul_interface bus;

  `uvm_component_utils_begin(tlul_driver)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "tlul_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task reset();
  extern virtual task send_stimulus_data(tlul_xaction tr);
  extern virtual function void drv_random();

endclass

function tlul_driver::new(string name = "tlul_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void tlul_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual tlul_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(tlul_driver_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = tlul_driver_cfg::type_id::create("cfg");
  end
endfunction

task tlul_driver::run_phase(uvm_phase phase);
  tlul_xaction tr;
  reset();
  forever begin
    seq_item_port.get_next_item(tr);
    drv_random();
    send_stimulus_data(tr);
    seq_item_port.item_done();
  end
endtask

task tlul_driver::reset();
  bus.drv_cb.a_valid   <= 1'b0;
  bus.drv_cb.a_opcode  <= '0;
  bus.drv_cb.a_param   <= '0;
  bus.drv_cb.a_size    <= '0;
  bus.drv_cb.a_source  <= '0;
  bus.drv_cb.a_address <= '0;
  bus.drv_cb.a_mask    <= '0;
  bus.drv_cb.a_data    <= '0;
  bus.drv_cb.d_ready   <= 1'b1;  // Always ready to accept D-channel response
  @(bus.drv_cb);
  // Wait for reset release (with bounded timeout to avoid hanging)
  fork
    begin
      wait(bus.rst_n === 1'b1);
    end
    begin
      #10000ns;
    end
  join_any
  disable fork;
endtask

task tlul_driver::send_stimulus_data(tlul_xaction tr);
  // Idle cycles before transaction
  repeat (cfg.idle_cycles) @(bus.drv_cb);

  // Drive A channel request
  bus.drv_cb.a_valid   <= 1'b1;
  bus.drv_cb.a_opcode  <= (tr.cmd == TLUL_WRITE) ? TLUL_PUTFULLDATA : TLUL_GET;
  bus.drv_cb.a_param   <= 3'h0;
  bus.drv_cb.a_size    <= 2'h2;  // 4-byte
  bus.drv_cb.a_source  <= '0;
  bus.drv_cb.a_address <= tr.addr;
  bus.drv_cb.a_mask    <= tr.strb;
  bus.drv_cb.a_data    <= tr.data;

  // Give the clocking output one edge to propagate a_valid to the interface,
  // then wait for the a_valid && a_ready handshake.
  @(bus.drv_cb);
  do begin
    @(bus.drv_cb);
  end while (!(bus.a_valid && bus.drv_cb.a_ready));

  // Deassert a_valid
  bus.drv_cb.a_valid <= 1'b0;

  // Wait for D channel response (with bounded timeout)
  begin
    int unsigned wait_cnt = 0;
    do begin
      @(bus.drv_cb);
      wait_cnt++;
      if (wait_cnt > cfg.timeout_cycles) begin
        `uvm_fatal(get_type_name(), $sformatf(
          "Timed out waiting for D channel response (addr=0x%0h)", tr.addr
        ))
      end
    end while (bus.drv_cb.d_valid !== 1'b1);
  end

  // Capture response
  tr.resp = bus.drv_cb.d_error ? TLUL_RESP_ERROR : TLUL_RESP_OK;
  if (tr.cmd == TLUL_READ) begin
    tr.data = bus.drv_cb.d_data;
  end

  // Idle cycles after transaction
  repeat (cfg.idle_cycles) @(bus.drv_cb);
endtask

function void tlul_driver::drv_random();
  // Randomized idle delays could be added here
endfunction

`endif
