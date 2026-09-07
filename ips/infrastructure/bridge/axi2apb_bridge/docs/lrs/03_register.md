# 寄存器需求 - AXI-to-APB Bridge (X2P)

> **类别状态：N/A - 纯桥无寄存器**

X2P 是可参数化 AXI-to-APB 桥，无可编程寄存器空间。所有配置通过编译期参数
（`AXI_PROFILE` / `APB_PROFILE` / `READ_REQUEST_DEPTH` / `WRITE_REQUEST_DEPTH`
/ `ARB_POLICY` / `ARB_GRANULARITY` / `TIMEOUT_ENABLE` / `TIMEOUT_CYCLES` /
`CLOCK_MODE` / `CDC_REQ_DEPTH` / `CDC_RSP_DEPTH` / `AXI_INPUT_REG` /
`AXI_OUTPUT_REG` / `APB_OUTPUT_REG`）完成。

本 IP 的 `register_model = none`，不生成 SystemRDL / CSR / C header。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*