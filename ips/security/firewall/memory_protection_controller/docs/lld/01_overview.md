# AXI Memory Protection Unit — LLD 概览

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 概览

AXI MPU 是 Generator IP，微架构按 HLD 模块分解：

| LLD 模块 | RTL 文件 | 说明 |
|----------|----------|------|
| `axi_mpu` (TOP) | `rtl/axi_mpu.sv` | 顶层参数化 + 实例化 |
| `axi_mpu_pkg` | `rtl/axi_mpu_pkg.sv` | 包定义（参数、类型、deny_reason 枚举） |
| `axi_mpu_read` | `rtl/axi_mpu_read.sv` | Read path（AR 捕获/转发/DECERR） |
| `axi_mpu_write` | `rtl/axi_mpu_write.sv` | Write path（AW/W/队列/DECERR） |
| `axi_mpu_permission` | `rtl/axi_mpu_permission.sv` | 权限引擎 |
| `axi_mpu_region_match` | `rtl/axi_mpu_region_match.sv` | Region 比较器 |
| `axi_mpu_error_resp` | `rtl/axi_mpu_error_resp.sv` | 本地错误响应 |
| `axi_mpu_violation` | `rtl/axi_mpu_violation.sv` | violation 捕获/计数/IRQ |
| `axi_mpu_regs` | `rtl/generated/axi_mpu_csr.sv` | PeakRDL 生成 CSR + 特殊行为 |
| `axi_mpu_master_attr` | `rtl/axi_mpu_master_attr.sv` | Master 属性 |

## 2. 关键微架构决策

1. **Read path**：AR 捕获 → 组合权限判定 → 合法转发 / 非法入本地 responder；
2. **Write path**：AW 捕获 → 权限判定 → Write Decision Queue 记录 → W beats 关联
   消费 → 合法转发 / 非法本地 B DECERR；
3. **Permission Engine**：Burst Analyzer + Region Matcher（并行）+ Priority Select
   （Lowest Index）+ Permission Checker；
4. **Violation**：FIRST_ERROR_STICKY 捕获，计数器饱和，IRQ sticky W1C；
5. **寄存器**：PeakRDL 生成 CSR，Region/Global Lock 保护。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
