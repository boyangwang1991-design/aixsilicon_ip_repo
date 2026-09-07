# X2P 集成指南

> 文档版本: v1.0 · 日期: 2026-09-03

## 1. 概述

X2P 是 AXI-to-APB Bridge（1 AXI Slave → 1 APB Master），通过参数化适配
AXI4/AXI4-Lite 与 APB3/APB4。本指南说明如何集成到 SoC。

## 2. 实例化

```systemverilog
x2p_top #(
  .AXI_ADDR_WIDTH(32), .AXI_DATA_WIDTH(64), .AXI_ID_WIDTH(4),
  .APB_ADDR_WIDTH(32), .APB_DATA_WIDTH(32),
  .AXI_PROFILE(1), .APB_PROFILE(1),
  .READ_REQUEST_DEPTH_LOG2(2), .WRITE_REQUEST_DEPTH_LOG2(2),
  .ARB_POLICY(0), .ARB_GRANULARITY(0),
  .TIMEOUT_ENABLE(1'b1), .TIMEOUT_CYCLES(256),
  .CLOCK_MODE(0), .CDC_REQ_DEPTH_LOG2(2), .CDC_RSP_DEPTH_LOG2(2),
  .AXI_INPUT_REG(1'b0), .AXI_OUTPUT_REG(1'b0), .APB_OUTPUT_REG(1'b1)
) u_x2p (
  .aclk(aclk), .aresetn(aresetn), .pclk(pclk), .presetn(presetn),
  // AXI slave / APB master 端口接法见 rtl/x2p_top.sv
);
```

## 3. 时钟与复位

- SYNC：aclck 与 pclk 同域或确定同步；CDC 逻辑 generate-out。
- ASYNC：aclck/pclk 异步，需配置 CDC_REQ/RSP_DEPTH，两域复位可独立。

## 4. 参数合法性

- AXI_DATA_WIDTH ∈ {32,64,128}；APB_DATA_WIDTH ∈ {32,64}；Power-of-Two ratio。
- Depth ∈ {1,2,4,8}（log2 参数 0-3）。
- AXI4-Lite 不支持 WRAP/outstanding>1 语义。
- APB3 写 partial 返回 SLVERR（不做 RMW）。

## 5. 待确认/已知问题

- **BUG-001**：AXI 读路径 RVALID 未建立（open），集成前需修复验证。