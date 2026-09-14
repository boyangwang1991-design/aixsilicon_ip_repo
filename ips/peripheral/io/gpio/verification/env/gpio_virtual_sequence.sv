// =============================================================================
// File Name   : gpio_virtual_sequence.sv
// Description : YY virtual sequence for coordinating multiple agents
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
//
// NOTE: UVM 1.2 Compatibility
//   In UVM 1.2, start_item() and finish_item() do NOT accept a sequencer
//   argument. Use tr.set_sequencer() before start_item() to target a specific
//   agent sequencer via the virtual sequencer's p_sequencer handle.
// =============================================================================

`ifndef GPIO_VIRTUAL_SEQUENCE__SV
`define GPIO_VIRTUAL_SEQUENCE__SV

/// @class gpio_base_vseq
/// @brief Base virtual sequence for YY environment
///        Provides APB read/write helper tasks using p_sequencer handles
class gpio_base_vseq extends uvm_sequence;

  `uvm_object_utils(gpio_base_vseq)
  `uvm_declare_p_sequencer(gpio_virtual_sequencer)

  extern function new(string name = "gpio_base_vseq");

  /// @brief APB write helper - write a value to a register address
  /// @param addr Register address
  /// @param data Data to write
  extern task apb_write(input bit [31:0] addr, input bit [31:0] data);

  /// @brief APB read helper - read a value from a register address
  /// @param addr Register address
  /// @param data Output read data
  extern task apb_read(input bit [31:0] addr, output bit [31:0] data);

endclass

// =============================================================================
// Function definitions
// =============================================================================

function gpio_base_vseq::new(string name = "gpio_base_vseq");
  super.new(name);
endfunction

task gpio_base_vseq::apb_write(input bit [31:0] addr, input bit [31:0] data);
  apb_xaction tr;
  tr = apb_xaction::type_id::create("tr");
  // UVM 1.2: set sequencer before start_item (no sequencer arg in finish_item)
  tr.set_sequencer(p_sequencer.apb_sqr);
  start_item(tr);
  `uvm_info("VSEQ", $sformatf("XX WRITE addr=0x%0h data=0x%0h", addr, data), UVM_HIGH)
  void'(tr.randomize() with {
    cmd  == APB_WRITE;
    addr == local::addr;
    data == local::data;
  });
  finish_item(tr);
endtask

task gpio_base_vseq::apb_read(input bit [31:0] addr, output bit [31:0] data);
  apb_xaction tr;
  tr = apb_xaction::type_id::create("tr");
  // UVM 1.2: set sequencer before start_item
  tr.set_sequencer(p_sequencer.apb_sqr);
  start_item(tr);
  void'(tr.randomize() with {
    cmd  == APB_READ;
    addr == local::addr;
  });
  finish_item(tr);
  data = tr.data;
  `uvm_info("VSEQ", $sformatf("XX READ addr=0x%0h data=0x%0h", addr, data), UVM_HIGH)
endtask


/// @class gpio_sanity_vseq
/// @brief Sanity virtual sequence - basic functionality test
///        Override body() with DUT-specific stimulus
class gpio_sanity_vseq extends gpio_base_vseq;

  `uvm_object_utils(gpio_sanity_vseq)

  extern function new(string name = "gpio_sanity_vseq");
  extern virtual task body();

endclass

function gpio_sanity_vseq::new(string name = "gpio_sanity_vseq");
  super.new(name);
endfunction

task gpio_sanity_vseq::body();
  `uvm_info(get_type_name(), "=== Start yy sanity virtual sequence ===", UVM_LOW)

  // TODO: Add DUT-specific stimulus here:
  //   apb_write(ADDR_CONFIG, 32'h0000_1234);
  //   apb_write(ADDR_CONTROL, 32'h0000_0001);  // START
  //   ... wait for done ...

  `uvm_info(get_type_name(), "=== End yy sanity virtual sequence ===", UVM_LOW)
endtask

`endif
