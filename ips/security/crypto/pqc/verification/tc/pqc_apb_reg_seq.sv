// =============================================================================
// File Name   : pqc_apb_reg_seq.sv
// Description : Single-access APB register sequence for directed tests
//
// UVM sequences are the only public stimulus API of the APB VIP (ADR-13), and
// the VIP's base sequence already implements the correct item handshake
// (start_item/finish_item). Directed tests therefore start one of these
// single-access sequences per register access instead of hand-rolling the
// handshake, so the PQC side never duplicates VIP behaviour.
// =============================================================================

`ifndef PQC_APB_REG_SEQ__SV
`define PQC_APB_REG_SEQ__SV

class pqc_apb_reg_seq extends apb_base_sequence;

  `uvm_object_utils(pqc_apb_reg_seq)

  bit                       is_write = 1'b1;
  logic [31:0]              addr     = 32'h0;
  logic [31:0]              data     = 32'h0;
  logic [3:0]               strb     = 4'hf;
  // PPROT for the transfer; the key-slot window (>=0x200) needs PPROT=3'b001.
  apb_protection            prot     = '{default: 1'b0};

  // Results for a read
  logic [31:0]              rdata    = 32'h0;
  bit                       slverr   = 1'b0;

  function new(string name = "pqc_apb_reg_seq");
    super.new(name);
  endfunction

  task body();
    apb_item it = apb_item::type_id::create("it");
    start_item(it);
    it.start_delay = 1; // Align the VIP clocking-block SETUP after idle submissions.
    it.direction = is_write ? APB_WRITE : APB_READ;
    it.addr      = addr;
    it.wdata     = data;
    it.strb      = is_write ? strb : 4'h0;   // reads must carry PSTRB = 0
    it.prot      = prot;
    finish_item(it);
    rdata = it.rdata;
    slverr = it.slverr;
  endtask

endclass

`endif // PQC_APB_REG_SEQ__SV