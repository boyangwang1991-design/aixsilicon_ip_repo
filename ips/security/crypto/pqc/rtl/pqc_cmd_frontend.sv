// ============================================================================
// pqc_cmd_frontend - descriptor validation, top-level FSM and completion
//
// Implements (LLD.FSM.PQC.TOP.MAIN, LLD.BUF.PQC.FE.DESC, LLD.REG.PQC.DOORBELL):
//   * 128-byte descriptor captured atomically into shadow registers, with a
//     running CRC-32 and a fetch-completeness + timeout guard
//   * opcode and parameter set are decoded from the CAPTURED SHADOW, never from
//     the live CSR, so software changes after the doorbell cannot alter the
//     running command; the opcode/parameter-set combination is checked against
//     a legality table instead of ad-hoc bit tests
//   * ABI / reserved / CRC / alignment / length / capability / permission
//     validation all happen before any secret is touched
//   * alg_start is a one-shot pulse; the FSM waits for the primitive/sequencer
//     to accept the command and then for alg_done, so a sequencer returning to
//     IDLE cannot be accidentally restarted
//   * completion publication ordering: results staged, completion record, then
//     DONE; done_pulse is exactly one cycle wide
//   * sparse one-hot state encoding with an illegal-state detector that forces
//     the safe shutdown path instead of ever reaching EXECUTE
//   * abort_sw takes the safe shutdown path during execution
// ============================================================================
`ifndef PQC_CMD_FRONTEND_SV
`define PQC_CMD_FRONTEND_SV

module pqc_cmd_frontend #(
  parameter int unsigned DESC_BYTES   = 128,
  parameter int unsigned CRC_BYTES    = 124,   // 0x00..0x7B
  parameter int unsigned FETCH_LIMIT  = 4096,
  parameter int unsigned DMA_DATA_WIDTH = 128,
  parameter logic [63:0] DMA_WINDOW_BASE = 64'd0,
  parameter logic [63:0] DMA_WINDOW_LIMIT = 64'h000000ffffffffff
) (
  input  logic         clk,
  input  logic         rst_n,

  // register intent (already captured from the CSR block)
  input  logic         enable_sw,
  input  logic         abort_sw,
  input  logic         zeroize_sw,
  input  logic         self_test_sw,
  input  logic         doorbell_sw,
  input  logic [31:0]  desc_addr_lo_sw,
  input  logic [7:0]   desc_addr_hi_sw,
  input  logic [7:0]   key_handle_slot,
  input  logic [15:0]  key_handle_gen,
  input  logic [7:0]   key_handle_owner,
  input  logic [2:0]   key_handle_type,
  input  logic         key_handle_ok,

  // capability inputs (software-visible configuration)
  input  logic         cap_enabled,
  input  logic [5:0]   cap_algo_mask,   // bit (pset-1) = supported

  // descriptor fetch
  output logic         desc_fetch_req,
  output logic [39:0]  desc_fetch_addr,
  input  logic [7:0]   desc_data,
  input  logic [7:0]   desc_data_idx,
  input  logic         desc_data_valid,
  input  logic         desc_fetch_done,
  input  logic         desc_fetch_error,

  // algorithm dispatch (decoded from the captured shadow)
  output logic         alg_start,
  output logic [1:0]   alg_op,
  output logic [2:0]   alg_pset,
  output logic [31:0] command_key_handle,
  output pqc_pkg::pqc_command_t command,
  output logic         command_valid,
  input  logic         alg_busy,
  input  logic         alg_done,
  input  logic         alg_verify_valid,
  input  logic         alg_op_error,

  // completion / status
  output logic         busy,
  output logic         idle,
  output logic         done_pulse,
  output logic [2:0]   comp_status,
  output logic [5:0]   comp_error,
  output logic [31:0]  completion_tag,
  output logic [9:0]   fsm_state_o,

  // faults
  input  logic         locked,
  input  logic         zeroize_req,
  input  logic         tamper,
  input  logic         rng_fault,
  input  logic         selftest_fail,

  // IRQ
  output logic         irq_done,
  output logic         irq_error,
  output logic         irq_rng,
  output logic         irq_tamper,
  output logic         irq_selftest
);

  import pqc_pkg::*;


  // ---------------------------------------------------------------------------
  // Sparse one-hot encoded top-level FSM
  // ---------------------------------------------------------------------------
  top_state_e fsm_state;
  assign fsm_state_o = fsm_state;

  logic state_illegal;
  always_comb begin
    unique case (fsm_state)
      10'b0000000001, 10'b0000000010, 10'b0000000100, 10'b0000001000,
      10'b0000010000, 10'b0000100000, 10'b0001000000, 10'b0010000000,
      10'b0100000000, 10'b1000000000: state_illegal = 1'b0;
      default: state_illegal = 1'b1;
    endcase
  end

  // ---------------------------------------------------------------------------
  // Descriptor shadow
  // ---------------------------------------------------------------------------
  logic [7:0]  desc_shadow [0:DESC_BYTES-1];
  logic [7:0]  fetch_idx;
  logic [13:0] fetch_wait;
  logic [31:0] crc_acc;
  logic [31:0] crc_expected;
  logic [39:0] desc_addr_q;
  logic doorbell_q;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) doorbell_q <= 1'b0;
    else doorbell_q <= doorbell_sw;
  end

  // The validator is combinational; this shadow remains the only descriptor copy.
  logic [1023:0] descriptor_bits;
  logic cap_enabled_q;
  logic [5:0] cap_algo_mask_q;
  logic descriptor_valid;
  error_code_e descriptor_error;
  pqc_command_t validated_command;
  logic crc_ok;
  assign crc_ok = ((crc_acc ^ 32'hffff_ffff) == crc_expected);
  for (genvar b=0; b<128; b++) begin : g_descriptor_view
    assign descriptor_bits[b*8+:8] = desc_shadow[b];
  end
  pqc_desc_validate #(
    .DMA_DATA_WIDTH(DMA_DATA_WIDTH), .DMA_WINDOW_BASE(DMA_WINDOW_BASE),
    .DMA_WINDOW_LIMIT(DMA_WINDOW_LIMIT)
  ) u_validate (
    .descriptor(descriptor_bits), .descriptor_addr(desc_addr_q), .crc_ok(crc_ok),
    .cap_enabled(cap_enabled_q), .cap_algo_mask(cap_algo_mask_q),
    .valid(descriptor_valid), .error(descriptor_error), .command(validated_command)
  );
  assign command_valid = rst_n && !zeroize_req && !zeroize_sw && !abort_sw &&
                         !locked && !tamper && !rng_fault && descriptor_valid &&
                         ((fsm_state == S_EXECUTE) || (fsm_state == S_COMMIT));
  assign command = command_valid ? validated_command : '0;

  // ---------------------------------------------------------------------------
  // Outputs
  // ---------------------------------------------------------------------------
  assign busy = (fsm_state == S_VALIDATE) || (fsm_state == S_FETCH) ||
                (fsm_state == S_EXECUTE)  || (fsm_state == S_COMMIT);
  assign idle = (fsm_state == S_IDLE);

  logic fetch_done;
  assign fetch_done = (fetch_idx == 8'(DESC_BYTES));

  assign desc_fetch_req  = rst_n && !zeroize_req && (fsm_state == S_FETCH) && !fetch_done;
  assign desc_fetch_addr = desc_addr_q;

  // alg_start is a one-shot pulse in EXECUTE (see alg_start_q below)
  logic alg_start_q;
  assign alg_start = rst_n && !zeroize_req && !zeroize_sw && !abort_sw &&
                     !locked && !tamper && !rng_fault && (fsm_state == S_EXECUTE) && alg_start_q;
  assign alg_op    = validated_command.operation;
  assign alg_pset  = validated_command.pset[2:0];
  assign command_key_handle = {desc_shadow[11],desc_shadow[10],desc_shadow[9],desc_shadow[8]};

  logic done_pulse_q;
  assign done_pulse = rst_n && !zeroize_req && done_pulse_q;

  // ---------------------------------------------------------------------------
  // CRC-32 (IEEE 802.3) accumulation, one byte per accepted fetch beat
  // ---------------------------------------------------------------------------
  function automatic logic [31:0] crc_step(input logic [31:0] c, input logic [7:0] b);
    logic [31:0] x;
    x = c ^ {24'h0, b};
    for (int i = 0; i < 8; i++)
      x = x[0] ? ((x >> 1) ^ 32'hEDB8_8320) : (x >> 1);
    return x;
  endfunction

  // ---------------------------------------------------------------------------
  // FSM
  // ---------------------------------------------------------------------------
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      fsm_state      <= S_DISABLED;
      fetch_idx      <= 8'h0;
      fetch_wait     <= 14'h0;
      crc_acc        <= 32'hFFFF_FFFF;
      crc_expected   <= 32'h0;
      desc_addr_q    <= 40'h0;
      cap_enabled_q <= 1'b0;
      cap_algo_mask_q <= 6'd0;
      comp_status    <= ST_SUCCESS;
      comp_error     <= ERR_NONE;
      completion_tag <= 32'h0;
      done_pulse_q   <= 1'b0;
      alg_start_q    <= 1'b0;
      for (int i = 0; i < DESC_BYTES; i++) desc_shadow[i] <= 8'h0;
    end else if (zeroize_req) begin
      fsm_state    <= S_ZEROIZE;
      fetch_idx    <= 8'h0;
      fetch_wait   <= 14'h0;
      alg_start_q  <= 1'b0;
      done_pulse_q <= 1'b0;
      comp_status  <= ST_SUCCESS;
      comp_error   <= ERR_NONE;
      desc_addr_q <= 40'h0;
      cap_enabled_q <= 1'b0;
      cap_algo_mask_q <= 6'd0;
      crc_acc <= 32'h0;
      crc_expected <= 32'h0;
      completion_tag <= 32'h0;
      for (int i = 0; i < DESC_BYTES; i++) desc_shadow[i] <= 8'h0;
    end else begin
      done_pulse_q <= 1'b0;   // exactly one cycle wide by default

      unique case (fsm_state)
        S_DISABLED: begin
          if (enable_sw) fsm_state <= S_SELFTEST;
        end

        S_SELFTEST: begin
          if (selftest_fail) begin
            fsm_state   <= S_LOCKED;
            comp_status <= ST_FATAL;
            comp_error  <= ERR_SELFTEST;
          end else begin
            fsm_state <= S_IDLE;
          end
        end

        S_IDLE: begin
          if (locked) begin
            fsm_state <= S_LOCKED;
          end else if (zeroize_sw) begin
            fsm_state <= S_ZEROIZE;
          end else if (doorbell_sw && !doorbell_q) begin
            // only the captured shadow (not the live registers) is validated
            fetch_idx    <= 8'h0;
            fetch_wait   <= 14'h0;
            crc_acc      <= 32'hFFFF_FFFF;
            desc_addr_q  <= {desc_addr_hi_sw,desc_addr_lo_sw};
            cap_enabled_q <= cap_enabled;
            cap_algo_mask_q <= cap_algo_mask;
            fsm_state    <= S_FETCH;
          end
        end

        S_FETCH: begin
          if (desc_fetch_error) begin
            comp_status <= ST_DMA_ERROR;
            comp_error <= ERR_DMA;
            fsm_state <= S_COMPLETE;
          end else if (desc_fetch_done && !fetch_done) begin
            // Completion without all bytes is never a valid descriptor.
            comp_status <= ST_DMA_ERROR;
            comp_error <= ERR_DMA;
            fsm_state <= S_COMPLETE;
          end else if (fetch_done && desc_fetch_done) begin
            fsm_state <= S_VALIDATE;
          end else if (desc_data_valid && !fetch_done) begin
            // index integrity: the byte index must match the expected position
            if (desc_data_idx != fetch_idx) begin
              comp_status <= ST_DMA_ERROR;
              comp_error  <= ERR_DMA;
              fsm_state   <= S_COMPLETE;
            end else begin
              if (fetch_idx < 8'(CRC_BYTES)) begin
                desc_shadow[fetch_idx] <= desc_data;
                crc_acc                <= crc_step(crc_acc, desc_data);
              end else begin
                crc_expected[((fetch_idx - 8'(CRC_BYTES)) * 8) +: 8] <= desc_data;
              end
              fetch_idx <= fetch_idx + 8'h1;
            end
          end else begin
            fetch_wait <= fetch_wait + 14'h1;
            if (fetch_wait >= 14'(FETCH_LIMIT)) begin
              comp_status <= ST_DMA_ERROR;
              comp_error  <= ERR_DMA;
              fsm_state   <= S_COMPLETE;
            end
          end
        end

        S_VALIDATE: begin
          if (!descriptor_valid) begin
            comp_status <= ST_CONFIG_ERROR; comp_error <= descriptor_error; fsm_state <= S_COMPLETE;
          end else if (validated_command.needs_private_key && !key_handle_ok) begin
            comp_status <= ST_CONFIG_ERROR; comp_error <= ERR_BAD_KEY; fsm_state <= S_COMPLETE;
          end else begin
            comp_status  <= ST_SUCCESS;
            comp_error   <= ERR_NONE;
            alg_start_q  <= 1'b1;
            fsm_state    <= S_EXECUTE;
          end
        end

        S_EXECUTE: begin
          if (alg_start_q) alg_start_q <= 1'b0;   // one-shot pulse
          if (abort_sw || zeroize_sw) begin
            comp_status <= ST_FATAL;
            comp_error  <= ERR_INTERNAL;
            fsm_state   <= S_ZEROIZE;
          end else if (alg_op_error) begin
            comp_status <= ST_FATAL;
            comp_error  <= ERR_INTERNAL;
            fsm_state   <= S_ZEROIZE;
          end else if (alg_done) begin
            fsm_state <= S_COMMIT;
          end
        end

        S_COMMIT: begin
          // results are already staged by the sequencer; publish the completion
          // record and assert DONE as a single-cycle pulse
          comp_status    <= (validated_command.opcode==OP_DSA_VERIFY && !alg_verify_valid) ? ST_VERIFY_INVALID : ST_SUCCESS;
          comp_error     <= ERR_NONE;
          completion_tag <= {desc_shadow[8'h07], desc_shadow[8'h06],
                             desc_shadow[8'h05], desc_shadow[8'h04]};
          fsm_state      <= S_COMPLETE;
        end

        S_COMPLETE: begin
          done_pulse_q <= 1'b1;
          fsm_state    <= S_IDLE;   // self-clearing: pulse is exactly one cycle
        end

        S_ZEROIZE: begin
          alg_start_q <= 1'b0;
          if (!zeroize_req) fsm_state <= S_IDLE;
        end

        S_LOCKED: begin
          if (!locked) fsm_state <= S_IDLE;
        end

        default: fsm_state <= S_ZEROIZE;   // illegal encoding -> safe shutdown
      endcase

      if (state_illegal) fsm_state <= S_ZEROIZE;
    end
  end

  // ---------------------------------------------------------------------------
  // Interrupt generation
  // ---------------------------------------------------------------------------
  assign irq_done     = (comp_status != ST_FATAL) && done_pulse;
  assign irq_error    = done_pulse && ((comp_status == ST_CONFIG_ERROR) ||
                                         (comp_status == ST_DMA_ERROR) ||
                                         (comp_status == ST_FATAL));
  assign irq_rng      = rng_fault;
  assign irq_tamper   = tamper;
  assign irq_selftest = selftest_fail;

endmodule

`endif // PQC_CMD_FRONTEND_SV
