# AXI MPU - 集成指南（Integration Guide）

> **IP**: `axi_mpu` · **Version**: `1.0.0` · **VLNV**: `aixsilicon:ip:firewall:axi_mpu:1.0.0`

## 1. 概述

AXI MPU（Memory Protection Unit）是 Generator IP，提供 Region-based、
Default-Deny、Context-aware 的 AXI4 访问保护。本文描述 SoC 集成要点。

## 2. FuseSoC 集成

IP 根目录提供 `aixsilicon_ip_axi_mpu.core`，SoC 集成通过 FuseSoC `depend`
引用（由 aixsilicon_vip_repo / workspace 聚合配置统一拉取）：

```yaml
# 顶层 core 片段
dependencies:
  - aixsilicon:ip:firewall:axi_mpu:1.0.0
```

## 3. 参数化（Generator 配置）

通过 `generator/` 定义层生成实例（详见 docs/lrs/11_generator.md）：

| 参数 | 默认 | 说明 |
|---|---|---|
| ADDR_WIDTH | 48 | AXI 地址位宽 |
| DATA_WIDTH | 128 | AXI 数据位宽 |
| ID_WIDTH | 8 | AXI ID 位宽 |
| MASTER_NUM | 8 | Master 数量（mask 宽度） |
| MASTER_ID_WIDTH | 4 | Master identity sideband 位宽 |
| REGION_NUM | 16 | 保护 Region 数量（不要求 2 的幂） |
| READ/WRITE_OUTSTANDING | 8 | 读写 outstanding 深度 |
| HAS_EXECUTE / HAS_MASTER_ATTR / HAS_IRQ / HAS_VIOLATION_LOG | 1 | 特性裁剪 |
| PIPELINE | 0 | 权限引擎流水（0=组合 / 1=1 级） |
| WRAP_SUPPORT | 1 | WRAP burst 支持 |

## 4. 端口连接

| 组 | 信号 | 方向（相对 MPU） |
|---|---|---|
| 时钟复位 | `clk`, `arst_n`（低有效异步复位） | in |
| 上游 AXI4 | `s_axi_*`（AR/R/AW/W/B） | slave |
| Master 上下文 | `s_axi_ar_master_id`, `s_axi_aw_master_id` | in（sideband） |
| 下游 AXI4 | `m_axi_*` | master |
| 配置总线 | `s_apb_*`（APB4） | slave |
| 中断 | `irq` | out（viol_en && sticky） |

注意：`*_master_id` sideband 必须由系统互连正确生成（AxID 不等价于
Master Identity，见 LRS §7）。

## 5. 时钟/复位/电源

- 单时钟单域；配置总线与被保护数据通路同域（无 CDC）。
- `arst_n` 低有效异步复位、同步释放由系统保证。
- Reset 后默认全部 Region disabled → Default Deny，锁与状态清除。

## 6. Boot 流程建议

1. trusted firmware 通过 APB 配置 MASTER_ATTR 与 Region 表；
2. 置 REGION_LOCK / GLOBAL_LOCK 冻结策略（1->0 禁止，仅复位清除）；
3. 使能 IRQ_ENABLE.viol_en（可选）；
4. BOOT_BYPASS 默认关闭；如启用需由 non-secure 不可控的退出机制。

## 7. 静态检查与约束

- `constraints/` 提供 SDC 模板；28nm 综合证据见
  `reports/synth/dc_shell.log`（sc9_cmos28lp_base_hvt tt_nominal_max_1p00v_25c）。
- G3 检查结论：lint/elab 0 error，DC 0 error、no latch。

## 8. 交付物索引

- SystemRDL：`regs/axi_mpu.rdl`（CSR 结构 SSOT）
- 寄存器手册：`docs/generated/axi_mpu_regs.html`
- C header：`sw/include/axi_mpu_regs.h`
- 验证证据：`reports/regression/`、`reports/smoke/`、`reports/coverage/`
