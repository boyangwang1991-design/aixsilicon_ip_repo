// =============================================================================
// File Name   : uart_env_cfg.sv
// Description : YY environment configuration class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef UART_ENV_CFG__SV
`define UART_ENV_CFG__SV

/// @class uart_env_cfg
/// @brief Configuration class for YY environment
///        Aggregates all sub-component configurations (DUT, RM, checker, agents)
class uart_env_cfg extends uvm_object;

  uart_env_mode_e env_mode = UART_ENV_NORMAL;  ///< Environment operation mode

  uart_dut_cfg     dut_cfg;      ///< DUT configuration
  uart_rm_cfg      rm_cfg;       ///< Reference model configuration
  uart_checker_cfg checker_cfg;  ///< Checker configuration

  uart_interface_agent_cfg uart_agent_cfg;  ///< UART serial agent configuration
  tlul_interface_agent_cfg tlul_agent_cfg;  ///< TL-UL bus agent configuration
  apb_interface_agent_cfg  apb_agent_cfg;   ///< APB bus agent configuration

  bit enable_rm      = 1;  ///< Enable/disable reference model
  bit enable_checker = 1;  ///< Enable/disable checker
  bit enable_cov     = 1;  ///< Enable/disable coverage collection
  bit enable_tlul    = 1;  ///< Enable TL-UL agent (register access)
  bit enable_apb     = 0;  ///< Enable APB agent (APB access path)

  // ---------------------------------------------------------------------------
  // UVM Automation
  // ---------------------------------------------------------------------------
  `uvm_object_utils_begin(uart_env_cfg)
    `uvm_field_enum(uart_env_mode_e, env_mode, UVM_ALL_ON)
    `uvm_field_object(dut_cfg, UVM_ALL_ON)
    `uvm_field_object(rm_cfg, UVM_ALL_ON)
    `uvm_field_object(checker_cfg, UVM_ALL_ON)
    `uvm_field_object(uart_agent_cfg, UVM_ALL_ON)
    `uvm_field_object(tlul_agent_cfg, UVM_ALL_ON)
    `uvm_field_object(apb_agent_cfg, UVM_ALL_ON)
    `uvm_field_int(enable_rm, UVM_ALL_ON)
    `uvm_field_int(enable_checker, UVM_ALL_ON)
    `uvm_field_int(enable_cov, UVM_ALL_ON)
    `uvm_field_int(enable_tlul, UVM_ALL_ON)
    `uvm_field_int(enable_apb, UVM_ALL_ON)
  `uvm_object_utils_end

  /// @brief Constructor - creates default sub-component configurations
  /// @param name Configuration object name string
  extern function new(string name = "uart_env_cfg");

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
function uart_env_cfg::new(string name = "uart_env_cfg");
  super.new(name);

  dut_cfg      = uart_dut_cfg::type_id::create("dut_cfg");
  rm_cfg       = uart_rm_cfg::type_id::create("rm_cfg");
  checker_cfg  = uart_checker_cfg::type_id::create("checker_cfg");
  uart_agent_cfg = uart_interface_agent_cfg::type_id::create("uart_agent_cfg");
  tlul_agent_cfg = tlul_interface_agent_cfg::type_id::create("tlul_agent_cfg");
  apb_agent_cfg  = apb_interface_agent_cfg::type_id::create("apb_agent_cfg");
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void uart_env_cfg::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void uart_env_cfg::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

`endif
