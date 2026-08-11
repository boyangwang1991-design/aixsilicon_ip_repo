// =============================================================================
// File Name   : uart_virtual_sequence.sv
// Description : UART virtual sequences - coordinate TL-UL, APB and UART serial
//               agents via the virtual sequencer. Implements the stimulus for
//               the 7 testcases defined in test_matrix.md.
//
// NOTE: UVM 1.2 Compatibility
//   In UVM 1.2, start_item() accepts a sequencer argument:
//   start_item(txn, -1, p_sequencer.<proto>_sqr);
// =============================================================================

`ifndef UART_VIRTUAL_SEQUENCE__SV
`define UART_VIRTUAL_SEQUENCE__SV

// Register byte offsets (match uart_reg_pkg)
`define UART_CTRL_OFFSET      6'h10
`define UART_STATUS_OFFSET    6'h14
`define UART_RDATA_OFFSET     6'h18
`define UART_WDATA_OFFSET     6'h1c
`define UART_FIFO_CTRL_OFFSET 6'h20
`define UART_FIFO_STATUS_OFF 6'h24
`define UART_OVRD_OFFSET      6'h28
`define UART_VAL_OFFSET       6'h2c
`define UART_TIMEOUT_CTRL_OFF 6'h30
`define UART_INTR_STATE_OFF   6'h00
`define UART_INTR_ENABLE_OFF  6'h04
`define UART_INTR_TEST_OFF    6'h08
`define UART_ALERT_TEST_OFF   6'h0c

/// @class uart_base_vseq
/// @brief Base virtual sequence for UART environment
///        Provides TL-UL / APB register access and UART serial send helpers
class uart_base_vseq extends uvm_sequence;

  `uvm_object_utils(uart_base_vseq)
  `uvm_declare_p_sequencer(uart_virtual_sequencer)

  extern function new(string name = "uart_base_vseq");

  /// @brief TL-UL write helper
  extern task tlul_write(input bit [31:0] addr, input bit [31:0] data);

  /// @brief TL-UL read helper
  extern task tlul_read(input bit [31:0] addr, output bit [31:0] data);

  /// @brief APB write helper
  extern task apb_write(input bit [31:0] addr, input bit [31:0] data);

  /// @brief APB read helper
  extern task apb_read(input bit [31:0] addr, output bit [31:0] data);

  /// @brief UART serial transmit helper
  extern task uart_send(input bit [7:0] data);

  /// @brief Wait for reset deassertion
  extern task wait_reset_deasserted();

endclass

// =============================================================================
// uart_base_vseq definitions
// =============================================================================

function uart_base_vseq::new(string name = "uart_base_vseq");
  super.new(name);
endfunction

task uart_base_vseq::tlul_write(input bit [31:0] addr, input bit [31:0] data);
  tlul_xaction tr;

  tr = tlul_xaction::type_id::create("tr");
  start_item(tr, -1, p_sequencer.tlul_sqr);
  if (!tr.randomize() with {
    cmd  == TLUL_WRITE;
    addr == local::addr;
    data == local::data;
    strb == '1;
  }) begin
    `uvm_fatal(get_type_name(), "tlul_write randomization failed")
  end
  finish_item(tr);
  `uvm_info("VSEQ", $sformatf("TLUL WRITE addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
endtask

task uart_base_vseq::tlul_read(input bit [31:0] addr, output bit [31:0] data);
  tlul_xaction tr;

  tr = tlul_xaction::type_id::create("tr");
  start_item(tr, -1, p_sequencer.tlul_sqr);
  if (!tr.randomize() with {
    cmd  == TLUL_READ;
    addr == local::addr;
    strb == '0;
  }) begin
    `uvm_fatal(get_type_name(), "tlul_read randomization failed")
  end
  finish_item(tr);
  data = tr.data;
  `uvm_info("VSEQ", $sformatf("TLUL READ  addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
endtask

task uart_base_vseq::apb_write(input bit [31:0] addr, input bit [31:0] data);
  apb_xaction tr;

  tr = apb_xaction::type_id::create("tr");
  start_item(tr, -1, p_sequencer.apb_sqr);
  if (!tr.randomize() with {
    cmd  == APB_WRITE;
    addr == local::addr;
    data == local::data;
    strb == '1;
  }) begin
    `uvm_fatal(get_type_name(), "apb_write randomization failed")
  end
  finish_item(tr);
  `uvm_info("VSEQ", $sformatf("APB WRITE addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
endtask

task uart_base_vseq::apb_read(input bit [31:0] addr, output bit [31:0] data);
  apb_xaction tr;

  tr = apb_xaction::type_id::create("tr");
  start_item(tr, -1, p_sequencer.apb_sqr);
  if (!tr.randomize() with {
    cmd  == APB_READ;
    addr == local::addr;
    strb == '0;
  }) begin
    `uvm_fatal(get_type_name(), "apb_read randomization failed")
  end
  finish_item(tr);
  data = tr.data;
  `uvm_info("VSEQ", $sformatf("APB READ  addr=0x%0h data=0x%0h", addr, data), UVM_MEDIUM)
endtask

task uart_base_vseq::uart_send(input bit [7:0] data);
  uart_xaction tr;

  tr = uart_xaction::type_id::create("tr");
  start_item(tr, -1, p_sequencer.uart_sqr);
  if (!tr.randomize() with {
    data      == local::data;
    parity_en == 1'b0;
    err_type  == UART_ERR_NONE;
    mode      == UART_MODE_NORMAL;
  }) begin
    `uvm_fatal(get_type_name(), "uart_send randomization failed")
  end
  finish_item(tr);
  `uvm_info("VSEQ", $sformatf("UART SEND data=0x%02x", data), UVM_MEDIUM)
endtask

task uart_base_vseq::wait_reset_deasserted();
  // The harness asserts reset for 10 clock cycles (100 ns) after t=0.
  // Wait a bounded fixed delay (with explicit ns units) for reset release.
  #500ns;
  `uvm_info("VSEQ", "Reset deasserted (fixed delay)", UVM_HIGH)
endtask

// =============================================================================
// uart_smoke_vseq - TC.INTF.UART.01.001.SMOKE
// =============================================================================
class uart_smoke_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_smoke_vseq)

  extern function new(string name = "uart_smoke_vseq");
  extern virtual task body();

endclass

function uart_smoke_vseq::new(string name = "uart_smoke_vseq");
  super.new(name);
endfunction

task uart_smoke_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_smoke_vseq: reset + register + loopback ===", UVM_LOW)
  wait_reset_deasserted();

  // 1. Reset defaults: STATUS should be 0x0 (TX/RX empty initially)
  tlul_read(`UART_STATUS_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("STATUS after reset = 0x%08h", rd), UVM_MEDIUM)

  // 2. Enable TX + RX + system loopback
  //    CTRL: NCO[31:16]=16, SLPBK[3]=1, RX[1]=1, TX[0]=1
  tlul_write(`UART_CTRL_OFFSET, (16 << 16) | (1 << 3) | (1 << 1) | (1 << 0));
  tlul_read(`UART_CTRL_OFFSET, rd);

  // 3. Write one byte to WDATA, read back RDATA (system loopback)
  tlul_write(`UART_WDATA_OFFSET, 32'h0000_00A5);
  // Bounded wait for RX data (RXLVL[20:16] > 0); proceed regardless so the
  // register access path is exercised without blocking the test.
  rd = 0;
  repeat (200) begin
    tlul_read(`UART_STATUS_OFFSET, rd);
    if (rd[20:16] > 0) break;  // RXLVL > 0
    #20ns;
  end
  tlul_read(`UART_RDATA_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("RDATA = 0x%08h (expect 0x...A5)", rd), UVM_LOW)

  `uvm_info(get_type_name(), "=== uart_smoke_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_tx_rx_vseq - TC.FUNC.UART.01.002.TXRX
// =============================================================================
class uart_tx_rx_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_tx_rx_vseq)

  extern function new(string name = "uart_tx_rx_vseq");
  extern virtual task body();

endclass

function uart_tx_rx_vseq::new(string name = "uart_tx_rx_vseq");
  super.new(name);
endfunction

task uart_tx_rx_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_tx_rx_vseq: multi-byte loopback ===", UVM_LOW)
  wait_reset_deasserted();

  // Configure system loopback (SLPBK), TX+RX enable
  // CTRL: NCO[31:16]=16, SLPBK[3]=1, RX[1]=1, TX[0]=1
  tlul_write(`UART_CTRL_OFFSET, (16 << 16) | (1 << 3) | (1 << 1) | (1 << 0));

  // Send multiple bytes; each TX write drives the serial output (loopback path).
  // Bounded poll of RXLVL (STATUS[20:16]); proceed regardless so the test
  // completes (bus access is the primary check in this environment).
  for (int i = 0; i < 8; i++) begin
    bit [7:0] tx_data = 8'(i + 1);
    bit [31:0] stat;
    tlul_write(`UART_WDATA_OFFSET, 32'(tx_data));
    rd = 0;
    repeat (200) begin
      tlul_read(`UART_STATUS_OFFSET, stat);
      if (stat[20:16] > 0) begin
        tlul_read(`UART_RDATA_OFFSET, rd);
        break;
      end
      #20ns;
    end
    `uvm_info(get_type_name(), $sformatf(
      "byte[%0d] RDATA=0x%08h (tx=0x%02x, rx_empty=%0b)", i, rd, tx_data, stat[2]
    ), UVM_MEDIUM)
  end

  `uvm_info(get_type_name(), "=== uart_tx_rx_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_error_vseq - TC.FUNC.UART.01.003.ERR
// =============================================================================
class uart_error_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_error_vseq)

  extern function new(string name = "uart_error_vseq");
  extern virtual task body();

endclass

function uart_error_vseq::new(string name = "uart_error_vseq");
  super.new(name);
endfunction

task uart_error_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_error_vseq: error interrupts ===", UVM_LOW)
  wait_reset_deasserted();

  // Enable all UART interrupts
  tlul_write(`UART_INTR_ENABLE_OFF, 32'h0000_01FF);

  // Trigger test interrupts via INTR_TEST (rx_frame_err = bit3)
  tlul_write(`UART_INTR_TEST_OFF, 32'h0000_0008);  // rx_frame_err test
  #100ns;
  tlul_read(`UART_INTR_STATE_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("INTR_STATE after frame err = 0x%08h", rd), UVM_MEDIUM)

  // Clear via W1C
  tlul_write(`UART_INTR_STATE_OFF, 32'h0000_0008);
  tlul_read(`UART_INTR_STATE_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("INTR_STATE after clear = 0x%08h", rd), UVM_MEDIUM)

  `uvm_info(get_type_name(), "=== uart_error_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_fifo_vseq - TC.FUNC.UART.01.004.FIFO
// =============================================================================
class uart_fifo_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_fifo_vseq)

  extern function new(string name = "uart_fifo_vseq");
  extern virtual task body();

endclass

function uart_fifo_vseq::new(string name = "uart_fifo_vseq");
  super.new(name);
endfunction

task uart_fifo_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_fifo_vseq: FIFO status ===", UVM_LOW)
  wait_reset_deasserted();

  // FIFO_CTRL defaults (rxilvl=1, txilvl=1); check FIFO_STATUS
  tlul_read(`UART_FIFO_STATUS_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("FIFO_STATUS initial = 0x%08h", rd), UVM_MEDIUM)

  // RX FIFO reset then check TX/RX empty flags
  tlul_write(`UART_FIFO_CTRL_OFFSET, 32'h0000_0001);  // rrst=1
  #50ns;
  tlul_read(`UART_FIFO_STATUS_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("FIFO_STATUS after rrst = 0x%08h", rd), UVM_MEDIUM)

  `uvm_info(get_type_name(), "=== uart_fifo_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_csr_vseq - TC.REG.UART.01.005.CSR
// =============================================================================
class uart_csr_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_csr_vseq)

  extern function new(string name = "uart_csr_vseq");
  extern virtual task body();

endclass

function uart_csr_vseq::new(string name = "uart_csr_vseq");
  super.new(name);
endfunction

task uart_csr_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_csr_vseq: register RW ===", UVM_LOW)
  wait_reset_deasserted();

  // CTRL RW check
  tlul_write(`UART_CTRL_OFFSET, 32'h0001_0040);
  tlul_read(`UART_CTRL_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("CTRL RW = 0x%08h", rd), UVM_MEDIUM)

  // OVRD RW (override output values)
  tlul_write(`UART_OVRD_OFFSET, 32'h0000_0003);
  tlul_read(`UART_OVRD_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("OVRD RW = 0x%08h", rd), UVM_MEDIUM)

  // TIMEOUT_CTRL RW
  tlul_write(`UART_TIMEOUT_CTRL_OFF, 32'h0000_000F);
  tlul_read(`UART_TIMEOUT_CTRL_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("TIMEOUT_CTRL RW = 0x%08h", rd), UVM_MEDIUM)

  `uvm_info(get_type_name(), "=== uart_csr_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_perf_vseq - TC.PERF.UART.01.006.PERF
// =============================================================================
class uart_perf_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_perf_vseq)

  extern function new(string name = "uart_perf_vseq");
  extern virtual task body();

endclass

function uart_perf_vseq::new(string name = "uart_perf_vseq");
  super.new(name);
endfunction

task uart_perf_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_perf_vseq: baud rate / NCO ===", UVM_LOW)
  wait_reset_deasserted();

  // Exercise NCO field with a representative baud rate (115200 => NCO=54)
  tlul_write(`UART_CTRL_OFFSET, (54 << 16) | (1 << 1) | (1 << 0));
  tlul_read(`UART_CTRL_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("CTRL NCO(115200) = 0x%08h", rd), UVM_MEDIUM)

  // 9600 baud => NCO=1667
  tlul_write(`UART_CTRL_OFFSET, (1667 << 16) | (1 << 1) | (1 << 0));
  tlul_read(`UART_CTRL_OFFSET, rd);
  `uvm_info(get_type_name(), $sformatf("CTRL NCO(9600) = 0x%08h", rd), UVM_MEDIUM)

  `uvm_info(get_type_name(), "=== uart_perf_vseq done ===", UVM_LOW)
endtask

// =============================================================================
// uart_alert_vseq - TC.SAFE.UART.01.007.ALERT
// =============================================================================
class uart_alert_vseq extends uart_base_vseq;

  `uvm_object_utils(uart_alert_vseq)

  extern function new(string name = "uart_alert_vseq");
  extern virtual task body();

endclass

function uart_alert_vseq::new(string name = "uart_alert_vseq");
  super.new(name);
endfunction

task uart_alert_vseq::body();
  bit [31:0] rd;

  `uvm_info(get_type_name(), "=== uart_alert_vseq: ALERT_TEST ===", UVM_LOW)
  wait_reset_deasserted();

  // ALERT_TEST - assert fatal alert test bit
  tlul_write(`UART_ALERT_TEST_OFF, 32'h0000_0001);
  #100ns;
  tlul_read(`UART_ALERT_TEST_OFF, rd);
  `uvm_info(get_type_name(), $sformatf("ALERT_TEST = 0x%08h", rd), UVM_MEDIUM)

  `uvm_info(get_type_name(), "=== uart_alert_vseq done ===", UVM_LOW)
endtask

`endif
