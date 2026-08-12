// =============================================================================
// File Name   : uart_driver.sv
// Description : UART external driver - generates serial frames on rx line
// =============================================================================

`ifndef UART_DRIVER__SV
`define UART_DRIVER__SV

class uart_driver extends uvm_driver #(uart_xaction);

  uart_driver_cfg        cfg;
  virtual uart_interface bus;

  `uvm_component_utils_begin(uart_driver)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  extern function new(string name = "uart_driver", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task reset();
  extern virtual task send_stimulus_data(uart_xaction tr);
  extern virtual task send_bit(bit b, int unsigned div);
  extern virtual function void drv_random();

endclass

function uart_driver::new(string name = "uart_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void uart_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(virtual uart_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end
  if (!uvm_config_db #(uart_driver_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = uart_driver_cfg::type_id::create("cfg");
  end
endfunction

task uart_driver::run_phase(uvm_phase phase);
  uart_xaction tr;
  reset();
  forever begin
    seq_item_port.get_next_item(tr);
    drv_random();
    send_stimulus_data(tr);
    seq_item_port.item_done();
  end
endtask

task uart_driver::reset();
  bus.drv_cb.rx <= 1'b1;  // idle high
  wait(bus.rst_n === 1'b1);
endtask

task uart_driver::send_bit(bit b, int unsigned div);
  repeat (div) @(bus.drv_cb);
  bus.drv_cb.rx <= b;
endtask

task uart_driver::send_stimulus_data(uart_xaction tr);
  logic parity;
  int unsigned div;

  div = (tr.baud_div > 0) ? tr.baud_div : 16;

  // Idle (high) before frame
  repeat (cfg.idle_cycles) @(bus.drv_cb);
  bus.drv_cb.rx <= 1'b1;

  // Start bit (0)
  send_bit(1'b0, div);

  // 8 data bits, LSB first
  for (int i = 0; i < 8; i++) begin
    send_bit(tr.data[i], div);
  end

  // Optional parity bit
  if (tr.parity_en) begin
    parity = tr.parity_odd ? ^tr.data : ~^tr.data;
    send_bit(parity, div);
  end

  // Stop bit (1) - or frame error (stop=0)
  if (tr.err_type == UART_ERR_FRAME) begin
    send_bit(1'b0, div);
  end else begin
    send_bit(1'b1, div);
  end

  // Idle after frame
  repeat (cfg.idle_cycles) @(bus.drv_cb);
  bus.drv_cb.rx <= 1'b1;
endtask

function void uart_driver::drv_random();
endfunction

`endif
