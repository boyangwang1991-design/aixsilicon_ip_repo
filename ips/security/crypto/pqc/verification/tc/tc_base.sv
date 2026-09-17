// =============================================================================
// File Name   : tc_base.sv
// Description : Base test class for all test cases
// =============================================================================

`ifndef TC_BASE__SV
`define TC_BASE__SV

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import apb_package::*;

/// @class tc_base
/// @brief Base test class extending uvm_test
///        Creates and configures the YY environment for all tests
class tc_base extends uvm_test;

  pqc_env     env;      ///< Environment handle
  pqc_env_cfg env_cfg;  ///< Environment configuration handle

  `uvm_component_utils_begin(tc_base)
    `uvm_field_object(env_cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  /// @brief Constructor
  /// @param name   Test name string
  /// @param parent Parent component handle
  extern function new(string name = "tc_base", uvm_component parent = null);

  /// @brief Build phase - create environment and apply configuration
  /// @param phase Current phase handle
  extern virtual function void build_phase(uvm_phase phase);

  /// @brief Configure environment with default settings
  ///        Override in derived tests to customize configuration
  extern virtual function void configure_env();

  /// @brief Run phase - main test execution
  /// @param phase Current phase handle
  extern virtual task run_phase(uvm_phase phase);

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name   Test name string
/// @param parent Parent component handle
function tc_base::new(string name = "tc_base", uvm_component parent = null);
  super.new(name, parent);
endfunction

/// @brief Build phase definition
/// @param phase Current phase handle
function void tc_base::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Create environment configuration
  env_cfg = pqc_env_cfg::type_id::create("env_cfg");

  // Apply test-specific configuration
  configure_env();

  // Set configuration in config_db and create environment
  uvm_config_db #(pqc_env_cfg)::set(this, "env", "cfg", env_cfg);
  env = pqc_env::type_id::create("env", this);
endfunction

/// @brief Configure environment definition
function void tc_base::configure_env();
  // Agent configuration: active=1 (UVM_ACTIVE), mode=0 (MASTER)
  env_cfg.apb_agent_cfg.active     = 1;
  env_cfg.apb_agent_cfg.mode       = 0;
  env_cfg.apb_agent_cfg.enable_cov = 1;
  env_cfg.enable_rm           = 1;
  env_cfg.enable_checker      = 1;
  env_cfg.enable_cov          = 1;
endfunction

/// @brief Run phase definition
/// @param phase Current phase handle
task tc_base::run_phase(uvm_phase phase);
  super.run_phase(phase);
endtask

`endif
