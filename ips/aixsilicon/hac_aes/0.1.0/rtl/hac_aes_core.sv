// Copyright (c) 2026 AIXSILICON
// SPDX-License-Identifier: Apache-2.0
//
// hac_aes_core: AES/CRC 算法核心（Golden Example A，HAC-P0）。
// 状态：骨架（算法实现待填充）。本模块只含算法相关逻辑，不含系统协议。

module hac_aes_core #(
  parameter int unsigned DATA_W = 128
) (
  input  logic              clk,
  input  logic              rst_n,

  // 算法启动/完成（由 Wrapper 从 HAC-CTRL 语义映射）
  input  logic              start,
  input  logic [DATA_W-1:0] key,
  input  logic [DATA_W-1:0] block_in,
  output logic [DATA_W-1:0] block_out,
  output logic              done,
  output logic              busy,

  // 事件上报（Wrapper 转 HAC-EVENT）
  output logic              ecc_error,
  output logic              illegal_opcode
);

  // 骨架：组合直通占位（真实 AES/CRC 算法待实现）
  assign block_out = block_in ^ key;
  assign done      = start & ~busy;
  assign busy      = 1'b0;
  assign ecc_error = 1'b0;
  assign illegal_opcode = 1'b0;

endmodule : hac_aes_core
