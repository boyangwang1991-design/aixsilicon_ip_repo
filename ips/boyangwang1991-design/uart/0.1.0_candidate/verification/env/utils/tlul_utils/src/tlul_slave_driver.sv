// =============================================================================
// File Name   : tlul_slave_driver.sv
// Description : XX slave driver implementation
//               Replace 'xx' with actual protocol name (e.g., apb, axi, irq)
// =============================================================================

`ifndef TLUL_SLAVE_DRIVER__SV
`define TLUL_SLAVE_DRIVER__SV

/// @class tlul_slave_driver
/// @brief XX protocol slave/target driver
///        Extends uvm_driver to implement XX-specific slave behavior
///        Responds to master requests with configurable timing and data
/// NOTE: Replace 'uvm_sequence_item' with your transaction type (e.g., tlul_xaction)
class tlul_slave_driver extends uvm_driver #(uvm_sequence_item /* TODO: Replace with tlul_xaction */);

  // =============================================================================
  // Slave Driver Configuration and Virtual Interface
  // =============================================================================
  // Purpose: Hold reference to slave driver configuration object and virtual interface
  tlul_slave_driver_cfg  cfg;  // Slave driver configuration handle
  virtual tlul_interface bus; // Virtual interface handle

  `uvm_component_utils_begin(tlul_slave_driver)
    `uvm_field_object(cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Slave driver name string
  /// @param parent Parent component handle
  extern function new(string name = "tlul_slave_driver", uvm_component parent = null);

  /// @brief Build phase - get virtual interface and configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Run phase - main slave execution loop
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

  /// @brief Reset slave signals to idle state
  extern virtual task reset();

  /// @brief Send slave response to master request
  ///        Implements random ready delay for realistic behavior
  extern virtual task slave_response();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Slave driver name string
/// @param parent Parent component handle
function tlul_slave_driver::new(string name = "tlul_slave_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void tlul_slave_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Get virtual interface from config_db
  if (!uvm_config_db #(virtual tlul_interface)::get(this, "", "vif", bus)) begin
    `uvm_fatal(get_type_name(), "Cannot get virtual interface from config_db")
  end

  // Get configuration from config_db, or create default
  if (!uvm_config_db #(tlul_slave_driver_cfg)::get(this, "", "cfg", cfg)) begin
    cfg = tlul_slave_driver_cfg::type_id::create("cfg");
  end
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tlul_slave_driver::run_phase(uvm_phase phase);
  reset();

  // Monitor for valid A-channel requests and respond
  forever begin
    @(bus.mon_cb);

    if (bus.mon_cb.a_valid === 1'b1) begin
      slave_response();
    end
  end
endtask

/// @brief Reset slave signals definition
task tlul_slave_driver::reset();
  // TODO: Replace with your protocol-specific reset signals
  // Example:
  //   bus.slv_cb.ready <= 1'b0;
  //   bus.slv_cb.rdata <= '0;
  //   bus.slv_cb.resp  <= TLUL_RESP_OKAY;

  wait(bus.rst_n === 1'b1);
endtask

/// @brief Slave response definition
task tlul_slave_driver::slave_response();
  int unsigned delay;

  // Random delay for ready signal
  delay = $urandom_range(cfg.ready_delay_min, cfg.ready_delay_max);

  // TODO: Replace with your protocol-specific response logic
  // Example:
  //   // Assert ready after delay
  //   repeat (delay) begin
  //     bus.slv_cb.ready <= 1'b0;
  //     @(bus.slv_cb);
  //   end
  //
  //   // Drive response data and response code
  //   bus.slv_cb.ready <= 1'b1;
  //   bus.slv_cb.rdata <= cfg.default_rdata;
  //   bus.slv_cb.resp  <= cfg.default_resp;
  //
  //   @(bus.slv_cb);
  //
  //   // Deassert ready
  //   bus.slv_cb.ready <= 1'b0;
endtask

`endif
