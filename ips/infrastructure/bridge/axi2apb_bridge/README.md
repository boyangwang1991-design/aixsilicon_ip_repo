# axi2apb_bridge — AXI→APB Bridge（X2P）

> VLNV：`aixsilicon:ip:axi2apb_bridge:1.0.0`　领域：infrastructure/bridge　类型：ip
> 状态：G0–G3 通过；G4 因 BUG-001（RVALID 超时）未闭环，发行状态 blocking

## 简介

AXI4/AXI4-Lite → APB3/APB4 全功能桥（X2P）。支持写路径（APB write）已验证通过；
读路径存在已知缺陷 BUG-001（AR 请求未触发 APL 读访问，RVALID 超时），详见
[`docs/lld`](docs/lld/index.md:1) 与 [`model/quality.yaml`](model/quality.yaml:1)。

本 IP 由独立工作区 `ip_x2p` 迁入 ip-repo（2026-09-07），作为统一 IP 仓首个
`infrastructure/bridge` 领域工程包。

## 目录结构

```text
axi2apb_bridge/
├── axi2apb_bridge.core      # FuseSoC Core（VLNV: aixsilicon:ip:axi2apb_bridge:1.0.0）
├── ip-package.yaml          # ip-repo 统一 IP 包元数据
├── docs/                    # LRS / HLD / LLD / verification / integration / user_manual
├── model/                   # canonical YAML（requirements/architecture/micro_design/quality 等）
├── rtl/                     # x2p_*.sv（top: x2p_top）
├── verification/            # UVM env / tc / th / sim / unit_test
├── reports/                 # lint / elab / synth / smoke / quality
├── trace/                   # 追踪矩阵（req_to_hld / hld_to_lld / lld_to_rtl / req_to_test）
├── scripts/                 # 环境与工具脚本
├── sw/include/              # 软件寄存器头文件
└── release/                 # 发布候选（x2p_1.0.0_candidate）
```

## 资产

| 资产 | 路径 |
|---|---|
| IP Package | [`ip-package.yaml`](ip-package.yaml:1) |
| FuseSoC Core | [`axi2apb_bridge.core`](axi2apb_bridge.core:1) |
| RTL Top | [`rtl/x2p_top.sv`](rtl/x2p_top.sv:1) |
| 质量模型 | [`model/quality.yaml`](model/quality.yaml:1) |
| 门禁报告 | [`reports/quality/gate_report.md`](reports/quality/gate_report.md:1) |

## 质量状态

| Gate | 状态 |
|---|---|
| G0 LRS | pass |
| G1 HLD | pass |
| G2 LLD | pass |
| G3 RTL Ready | pass |
| G4 Verification Ready | **fail**（BUG-001 RVALID 超时，open） |
| G5 Release Ready | not_pass（依赖 G4） |

## 已知问题

- **BUG-001**（High，open）：AXI 读路径 RVALID 永不置位（R timeout）。读请求经 AR 队列
  入队后未产生 APL 读访问。修复计划与进展见 [`docs/lld/01_design.md`](docs/lld/01_design.md:1)。

## FuseSoC 使用

```bash
fusesoc library add aixsilicon_ip_repo .
fusesoc core show aixsilicon:ip:axi2apb_bridge:1.0.0
fusesoc run --target lint  aixsilicon:ip:axi2apb_bridge:1.0.0
fusesoc run --target elab  aixsilicon:ip:axi2apb_bridge:1.0.0
```
