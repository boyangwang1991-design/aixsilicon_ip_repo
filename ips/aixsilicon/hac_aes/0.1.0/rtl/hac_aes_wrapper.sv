// Copyright (c) 2026 AIXSILICON
// SPDX-License-Identifier: Apache-2.0
//
// hac_aes_wrapper: AES 算法专用 Wrapper（HAC Core ↔ HAC-IF 语义映射）。
// 状态：骨架。将 HAC-CTRL 命令/完成映射到算法核心，并产生 HAC-EVENT。
// 系统侧接口（AXI4-Lite CSR/IRQ）由 HAC Shell（CBB hac_shell 模板）提供。

module hac_aes_wrapper (
  input  logic clk,
  input  logic rst_n,

  // HAC-CTRL（core 视角）
  input  logic        cmd_valid,
  output logic        cmd_ready,
  input  logic [7:0]  cmd_opcode,
  input  logic [63:0] cmd_desc_addr,
  output logic        cpl_valid,
  input  logic        cpl_ready,
  output logic [7:0]  cpl_job_id,
  output logic [15:0] cpl_status,
  output logic        busy,
  output logic        idle,
  output logic        quiescent,

  // HAC-EVENT（core 视角）
  output logic        event_valid,
  input  logic        event_ready,
  output logic [2:0]  event_type,
  output logic [1:0]  severity,
  output logic [7:0]  event_source,
  output logic [7:0]  event_job_id,
  output logic [15:0] event_code,
  output logic [31:0] event_info,

  // 算法核心
  output logic              algo_start,
  output logic [127:0]      algo_key,
  output logic [127:0]      algo_block_in,
  input  logic [127:0]      algo_block_out,
  input  logic              algo_done,
  input  logic              algo_busy,
  input  logic              algo_ecc_error
);

  // 骨架：单任务映射（max_inflight_jobs=1）
  assign cmd_ready   = 1'b1;
  assign algo_start  = cmd_valid;
  assign cpl_valid   = algo_done;
  assign cpl_job_id  = 8'h0;
  assign cpl_status  = algo_ecc_error ? 16'h0300 : 16'h0000;
  assign busy        = algo_busy;
  assign idle        = ~algo_busy;
  assign quiescent   = ~algo_busy;

  // 事件：将算法错误转成 HAC-EVENT（Fatal / Recoverable）
  assign event_valid   = algo_ecc_error;
  assign event_type    = 3'd2; // HAC_EVT_FATAL
  assign severity      = 2'd2; // HAC_SEV_FATAL
  assign event_source  = 8'h01;
  assign event_job_id  = 8'h0;
  assign event_code    = 16'h0300; // ECC/Parity/硬件故障分区
  assign event_info    = 32'h0;

endmodule : hac_aes_wrapper
