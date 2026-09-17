// =============================================================================
// File Name   : pqc_fcov.sv
// Description : YY RM functional coverage transaction class
//               Replace 'yy' with actual DUT/subsystem name (e.g., dma, sram_ctrl)
// =============================================================================

`ifndef PQC_FCOV__SV
`define PQC_FCOV__SV

/// @class pqc_rm_fcov_xaction
/// @brief YY reference model functional coverage transaction
///        Extends uvm_sequence_item for coverage data collection
class pqc_rm_fcov_xaction extends uvm_sequence_item;

  // =============================================================================
  // Coverage Sample Fields
  // =============================================================================
  // Purpose: Fields to be sampled by the covergroup
  //          Replace with actual DUT-specific fields for coverage collection
  // Example:
  //   bit [31:0] addr;   // Address for coverage sampling
  //   bit [31:0] data;   // Data for coverage sampling
  //   apb_cmd_e   cmd;    // Command type for coverage sampling

  /// @brief Dummy field for template placeholder (replace with actual fields)
  bit [0:0] sample_data;

  /// @brief YY coverage group
  covergroup pqc_cg;
    option.per_instance = 1;

    // TODO: Add functional coverage points here based on actual sample fields
    //       Example: operation type, address ranges, data patterns, etc.
    // cp_cmd: coverpoint cmd {
    //   bins read  = {APB_READ};
    //   bins write = {APB_WRITE};
    // }
    // cp_addr: coverpoint addr[7:0];

    cp_sample: coverpoint sample_data {
      bins zero = {0};
      bins one  = {1};
    }

  endgroup

  `uvm_object_utils(pqc_rm_fcov_xaction)

  /// @brief Constructor
  /// @param name Coverage transaction name string
  extern function new(string name = "pqc_rm_fcov_xaction");

  // ---------------------------------------------------------------------------
  // UVM Hooks
  // ---------------------------------------------------------------------------

  /// @brief Pre-randomize hook, called before randomize()
  ///        Can be used to set dynamic constraints or pre-condition checks
  extern function void pre_randomize();

  /// @brief Post-randomize hook, called after randomize()
  ///        Can be used for post-processing or validation of randomized values
  extern function void post_randomize();

  // ---------------------------------------------------------------------------
  // Pack/Unpack
  // ---------------------------------------------------------------------------

  /// @brief Pack transaction fields into a byte stream
  /// @param packer Packer state object
  extern virtual function void do_pack(uvm_packer packer);

  /// @brief Unpack transaction fields from a byte stream
  /// @param packer Packer state object
  extern virtual function void do_unpack(uvm_packer packer);

  /// @brief Sample the coverage group
  extern virtual function void sample();

endclass

// =============================================================================
// Extern function definitions
// =============================================================================

/// @brief Constructor definition
/// @param name Coverage transaction name string
function pqc_rm_fcov_xaction::new(string name = "pqc_rm_fcov_xaction");
  super.new(name);
  pqc_cg = new();
endfunction

// ---------------------------------------------------------------------------
// UVM Hook definitions
// ---------------------------------------------------------------------------

/// @brief Pre-randomize hook
///        Add pre-randomization logic here (e.g., dynamic constraints)
function void pqc_rm_fcov_xaction::pre_randomize();
  super.pre_randomize();
  // TODO: Add pre-randomize logic here
endfunction

/// @brief Post-randomize hook
///        Add post-randomization validation/correction here
function void pqc_rm_fcov_xaction::post_randomize();
  super.post_randomize();
  // TODO: Add post-randomize logic here
endfunction

// ---------------------------------------------------------------------------
// Pack/Unpack definitions
// ---------------------------------------------------------------------------

/// @brief Pack transaction fields into a byte stream
/// @param packer Packer state object
function void pqc_rm_fcov_xaction::do_pack(uvm_packer packer);
  super.do_pack(packer);
  // TODO: Add custom pack logic if fields need special packing order/format
endfunction

/// @brief Unpack transaction fields from a byte stream
/// @param packer Packer state object
function void pqc_rm_fcov_xaction::do_unpack(uvm_packer packer);
  super.do_unpack(packer);
  // TODO: Add custom unpack logic if fields need special unpacking order/format
endfunction

/// @brief Sample definition
function void pqc_rm_fcov_xaction::sample();
  pqc_cg.sample();
endfunction

`endif
