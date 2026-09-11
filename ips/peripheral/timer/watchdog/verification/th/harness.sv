// =============================================================================
// File Name   : harness.sv
// Description : Top-level testbench harness
//               Contains clock/reset generation, interface instantiation,
//               DUT instantiation, and UVM configuration
// =============================================================================

`timescale 1ns/1ps

/// @module harness
/// @brief Top-level testbench module
///        - Generates clock and reset
///        - Instantiates protocol interfaces
///        - Configures UVM config_db with virtual interfaces
///        - Starts UVM test
module harness;

  // Import UVM and verification packages
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_package::*;

  // ---------------------------------------------------------------------------
  // Clock and Reset Generation
  // ---------------------------------------------------------------------------
  logic clk;    ///< System clock
  logic rst_n;  ///< Active-low reset

  // ---------------------------------------------------------------------------
  // Interface Instantiation
  // ---------------------------------------------------------------------------

  /// XX protocol interface instance
  apb_interface apb_if (
    .clk   (clk),
    .rst_n (rst_n)
  );

  // ---------------------------------------------------------------------------
  // DUT Instantiation (uncomment and modify for actual DUT)
  // ---------------------------------------------------------------------------

  // DUT instance
  // watchdog_dut u_dut (
  //   .clk   (clk),
  //   .rst_n (rst_n),
  //   ...
  // );

  // ---------------------------------------------------------------------------
  // Clock Generation
  // ---------------------------------------------------------------------------

  /// Generate 100MHz clock (10ns period)
  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  // ---------------------------------------------------------------------------
  // Reset Generation
  // ---------------------------------------------------------------------------

  /// Generate reset - assert for 10 clock cycles
  initial begin
    rst_n = 1'b0;
    repeat (10) @(posedge clk);
    rst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // UVM Configuration and Test Execution
  // ---------------------------------------------------------------------------

  /// Configure virtual interfaces in UVM config_db and start test
  initial begin
    // Set virtual interface at agent level; the agent forwards it to sub-components.
    uvm_config_db #(virtual apb_interface)::set(
      null,
      "uvm_test_top.env.apb_agent",
      "vif",
      apb_if
    );

    // Start UVM test
    run_test();
  end

endmodule
