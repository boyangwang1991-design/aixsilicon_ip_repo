# AXI Memory Protection Unit — LLD 全局约束

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 全局约束

### 1.1 时钟与复位

#### LLD.RESET.AXI_MPU.SYS 系统复位约束

<!-- LLD_RESET_META
id: LLD.RESET.AXI_MPU.SYS
module_ref: LLD.MOD.AXI_MPU.TOP
reset_domain: RST_SYS_N
type: async_active_low
release: synchronous
reset_value: 默认拒绝（所有 Region disabled）
modules:
  - LLD.MOD.AXI_MPU.TOP
req_ref:
  - LRS.RESET.AXI_MPU.RESET.001
END_LLD_RESET_META -->

### 1.2 CDC

#### LLD.CDC.AXI_MPU.NO_CDC 无 CDC 约束

<!-- LLD_CDC_META
id: LLD.CDC.AXI_MPU.NO_CDC
module_ref: LLD.MOD.AXI_MPU.TOP
source_domain: CLK_SYS
destination_domain: CLK_SYS
architecture_strategy: 单时钟域，无同步器需求；APB4 与 AXI datapath 同域
req_ref:
  - LRS.RESET.AXI_MPU.CLOCK.001
END_LLD_CDC_META -->

### 1.3 全局数据通路约束

- AXI datapath 位宽：`ADDR_WIDTH`/`DATA_WIDTH`/`ID_WIDTH`；
- Master ID 位宽：`MASTER_ID_WIDTH`；
- Region 数：`REGION_NUM`（不要求 2 的幂）；
- 队列深度：`READ_OUTSTANDING`/`WRITE_OUTSTANDING`；
- pipeline：`PIPELINE`（0/1）。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
