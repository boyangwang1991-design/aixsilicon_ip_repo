# AXI Memory Protection Unit — HLD 时钟/复位/CDC/性能

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟域

### 1.1 系统时钟域

#### HLD.DOMAIN.AXI_MPU.CLK_SYS 系统时钟域

<!-- HLD_DOMAIN_META
id: HLD.DOMAIN.AXI_MPU.CLK_SYS
type: clk
name: CLK_SYS
source: 外部输入 CLK
modules:
  - HLD.MOD.L1.AXI_MPU.TOP
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - HLD.MOD.L1.AXI_MPU.VIOLATION
  - HLD.MOD.L1.AXI_MPU.REG_FILE
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
req_ref:
  - LRS.RESET.AXI_MPU.CLOCK.001
END_HLD_DOMAIN_META -->

---

## 2. 复位域

### 2.1 系统复位域

#### HLD.DOMAIN.AXI_MPU.RST_SYS_N 系统复位域

<!-- HLD_DOMAIN_META
id: HLD.DOMAIN.AXI_MPU.RST_SYS_N
type: rst
name: RST_SYS_N
source: 外部输入 RST_N（异步低有效）
modules:
  - HLD.MOD.L1.AXI_MPU.TOP
  - HLD.MOD.L1.AXI_MPU.READ_FRONTEND
  - HLD.MOD.L1.AXI_MPU.WRITE_FRONTEND
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
  - HLD.MOD.L1.AXI_MPU.VIOLATION
  - HLD.MOD.L1.AXI_MPU.REG_FILE
  - HLD.MOD.L1.AXI_MPU.MASTER_ATTR
req_ref:
  - LRS.RESET.AXI_MPU.RESET.001
END_HLD_DOMAIN_META -->

---

## 3. 电源域

#### HLD.DOMAIN.AXI_MPU.PD_ALWAYS_ON 常开电源域

<!-- HLD_DOMAIN_META
id: HLD.DOMAIN.AXI_MPU.PD_ALWAYS_ON
type: pwr
name: PD_ALWAYS_ON
source: SoC 常开电源
modules:
  - HLD.MOD.L1.AXI_MPU.TOP
req_ref:
  - LRS.LP.AXI_MPU.LOW_POWER.001
END_HLD_DOMAIN_META -->

---

## 4. CDC / RDC

### 4.1 CDC 声明

#### HLD.CDC.AXI_MPU.NO_CDC 无 CDC 路径

<!-- HLD_CDC_META
id: HLD.CDC.AXI_MPU.NO_CDC
source_domain: CLK_SYS
destination_domain: CLK_SYS
architecture_strategy: V1.0 单时钟域，无异步 CDC 路径；AXI datapath 与 APB4 同域
req_ref:
  - LRS.RESET.AXI_MPU.CLOCK.001
END_HLD_CDC_META -->

---

## 5. 性能预算

### 5.1 吞吐预算

#### HLD.PERF.AXI_MPU.THROUGHPUT 吞吐预算

<!-- HLD_PERF_META
id: HLD.PERF.AXI_MPU.THROUGHPUT
metric: address_transactions_per_cycle
target: 1
allocated_to:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
req_ref:
  - LRS.PERF.AXI_MPU.THROUGHPUT.001
END_HLD_PERF_META -->

### 5.2 Pipeline 延迟预算

#### HLD.PERF.AXI_MPU.LATENCY Pipeline 延迟预算

<!-- HLD_PERF_META
id: HLD.PERF.AXI_MPU.LATENCY
metric: permission_pipeline_stages
target: 0-1
allocated_to:
  - HLD.MOD.L1.AXI_MPU.PERM_ENGINE
req_ref:
  - LRS.PERF.AXI_MPU.THROUGHPUT.002
  - LRS.CFG.AXI_MPU.PIPELINE.001
END_HLD_PERF_META -->

---

## 6. Generator 架构影响

### 6.1 Generator 规则

#### HLD.GEN.AXI_MPU.STRUCTURE Generator 结构规则

<!-- HLD_GEN_META
id: HLD.GEN.AXI_MPU.STRUCTURE
config_ref: REGION_NUM
architecture_effect: |
  REGION_NUM <= 4: Flat comparator；
  <= 16: Parallel comparator + priority tree；
  > 16: Hierarchical match + optional pipeline。
  MASTER_NUM 决定 MASTER_MASK 位宽与 MASTER_ATTR 数组长度。
  READ/WRITE_OUTSTANDING 决定队列深度。
req_ref:
  - LRS.GEN.AXI_MPU.STRUCTURE.001
  - LRS.CFG.AXI_MPU.REGION_NUM.001
END_HLD_GEN_META -->

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
