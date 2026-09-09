# APB Demux — LLD 交付映射（RTL_MAP_META）

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. RTL 映射

#### RTL.MAP.APB_DEMUX.TOP 顶层 RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.APB_DEMUX.TOP
rtl_module: rtl/apb_demux_top.sv
implements:
  - LLD.MOD.APB_DEMUX.TOP
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  单模块参数化 RTL，全部逻辑块（decode/route/err/timeout/response_register）
  在此文件内实现。无 regs/*.rdl（register_model=none）。
END_RTL_MAP_META -->

##### 需求描述

1. RTL 文件 `rtl/apb_demux_top.sv`。

---

## 2. 交付物清单

| 交付物 | 路径 | 所有者 |
|--------|------|--------|
| RTL 顶层 | `rtl/apb_demux_top.sv` | 07-rtl-code-generator |
| FuseSoC core | `aixsilicon_ip_apb_demux.core` | 08-fusesoc-packager |
| 配置校验脚本 | `scripts/check_config.py` | 19-param-space-verification |
| 参数空间模型 | `model/parameter_space.yaml` | 19-param-space-verification |

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
