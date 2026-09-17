// =============================================================================
// File Name   : pqc_env_cfg.sv
// Description : YY environment configuration class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_ENV_CFG__SV
`define PQC_ENV_CFG__SV

/// @class pqc_env_cfg
/// @brief Configuration class for YY environment
///        Aggregates all sub-component configurations (DUT, RM, checker, agents)
class pqc_env_cfg extends uvm_object;

  pqc_env_mode_e env_mode = PQC_ENV_NORMAL;  ///< Environment operation mode

  pqc_dut_cfg     dut_cfg;      ///< DUT configuration
  pqc_rm_cfg      rm_cfg;       ///< Reference model configuration
  pqc_checker_cfg checker_cfg;  ///< Checker configuration

  apb_interface_agent_cfg apb_agent_cfg;  ///< XX agent configuration

  bit enable_rm      = 1;  ///< Enable/disable reference model
  bit enable_checker = 1;  ///< Enable/disable checker
  bit enable_cov     = 1;  ///< Enable/disable coverage collection

  // ---------------------------------------------------------------------------
  // UVM Automation
  // ---------------------------------------------------------------------------
  `uvm_object_utils_begin(pqc_env_cfg)
    `uvm_field_enum(pqc_env_mode_e, env_mode, UVM_ALL_ON)
    `uvm_field_object(dut_cfg, UVM_ALL_ON)
    `uvm_field_object(rm_cfg, UVM_ALL_ON)
    `uvm_field_object(checker_cfg, UVM_ALL_ON)
    `uvm_field_object(apb_agent_cfg, UVM_ALL_ON)
    `uvm_field_int(enable_rm, UVM_ALL_ON)
    `uvm_field_int(enable_checker, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor - creates default sub-component configurations
  /// @param name Configuration object name string
  extern function new(string name = "pqc_env_cfg");

  // ---------------------------------------------------------------------------
  // UVM Hooks
  // ---------------------------------------------------------------------------

  /// @brief Pre-randomize hook, called before randomize()
  ///        Can be used to set dynamic constraints or pre-condition checks
  extern function void pre_randomize();

  /// @brief Post-randomize hook, called after randomize()
  ///        Can be used for post-processing or validation of randomized values
  extern function void post_randomize();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Configuration object name string
function pqc_env_cfg::new(string name = "pqc_env_cfg");
  super.new(name);

  dut_cfg      = pqc_dut_cfg::type_id::create("dut_cfg");
  rm_cfg       = pqc_rm_cfg::type_id::create("rm_cfg");
  checker_cfg  = pqc_checker_cfg::type_id::create("checker_cfg");
  apb_agent_cfg = apb_interface_agent_cfg::type_id::create("apb_agent_cfg");
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void pqc_env_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void pqc_env_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
