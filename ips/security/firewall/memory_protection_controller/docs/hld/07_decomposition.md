# AXI Memory Protection Unit — HLD LLD 分解建议

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. LLD 分解建议

| HLD 模块 | LLD 分解 | 说明 |
|----------|----------|------|
| `axi_mpu` (TOP) | 顶层参数化 + 实例化 | Generator 顶层 |
| `axi_mpu_read` | AR 捕获 FSM、Read Decision 跟踪、Local R DECERR responder | Read path |
| `axi_mpu_write` | AW 捕获 FSM、Write Decision Queue、W consume、Local B DECERR | Write path |
| `axi_mpu_permission` | Burst Analyzer、Region Matcher 阵列、Priority Select、Permission Checker | 权限引擎 |
| `axi_mpu_region_match` | 单 Region 比较器（可参数化 REGION_NUM 实例化） | 可拆出 |
| `axi_mpu_error_resp` | Local responder（R/B） | 错误响应 |
| `axi_mpu_violation` | violation 捕获/计数/IRQ | 记录 |
| `axi_mpu_regs` | PeakRDL 生成 CSR + 特殊 HW 行为 | 寄存器 |
| `axi_mpu_master_attr` | Master 属性存储 | 属性 |

## 2. 架构约束输出给 LLD

1. Region Matcher 必须并行可综合、优先级 Lowest Index Wins 确定性；
2. Write Decision Queue 深度 = `WRITE_OUTSTANDING`；
3. 非法事务不得进入 M_AXI；
4. 0/1-stage pipeline 可配置；
5. violation 捕获 FIRST_ERROR_STICKY；
6. Lock 仅 reset 清除。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
