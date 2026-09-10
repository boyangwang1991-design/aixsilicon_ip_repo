# AXI Memory Protection Unit — LLD 交付映射（RTL_MAP_META）

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. RTL 映射

#### RTL.MAP.AXI_MPU.TOP 顶层 RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.TOP
rtl_module: rtl/axi_mpu.sv
implements:
  - LLD.MOD.AXI_MPU.TOP
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  顶层参数化 + 实例化 read/write/permission/violation/regs/master_attr。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.READ Read Path RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.READ
rtl_module: rtl/axi_mpu_read.sv
implements:
  - LLD.MOD.AXI_MPU.READ
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  Read path：AR 捕获/转发/DECERR/outstanding。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.WRITE Write Path RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.WRITE
rtl_module: rtl/axi_mpu_write.sv
implements:
  - LLD.MOD.AXI_MPU.WRITE
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  Write path：AW/W/Write Decision Queue/DECERR。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.PERM Permission Engine RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.PERM
rtl_module: rtl/axi_mpu_permission.sv
implements:
  - LLD.MOD.AXI_MPU.PERM
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  Burst Analyzer + Region Matcher + Priority Select + Permission Checker。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.VIOLATION Violation RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.VIOLATION
rtl_module: rtl/axi_mpu_violation.sv
implements:
  - LLD.MOD.AXI_MPU.VIOLATION
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  violation 捕获/计数/IRQ。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.REGS Register File RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.REGS
rtl_module: rtl/generated/axi_mpu_csr.sv
implements:
  - LLD.MOD.AXI_MPU.REGS
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  PeakRDL 生成 CSR + 特殊 HW 行为（Lock/violation）。
END_RTL_MAP_META -->

#### RTL.MAP.AXI_MPU.MASTER_ATTR Master Attr RTL 映射

<!-- RTL_MAP_META
id: RTL.MAP.AXI_MPU.MASTER_ATTR
rtl_module: rtl/axi_mpu_master_attr.sv
implements:
  - LLD.MOD.AXI_MPU.MASTER_ATTR
language: systemverilog
profile: commercial-systemverilog
synthesizable: true
notes: |
  Master SECURE/NONSECURE_CAPABLE 存储。
END_RTL_MAP_META -->

---

## 2. 交付物清单

| 交付物 | 路径 | 所有者 |
|--------|------|--------|
| RTL 顶层 + 模块 | `rtl/*.sv` | 07-rtl-code-generator |
| 生成 CSR RTL | `rtl/generated/axi_mpu_csr.sv` | 02-reg-model (PeakRDL) |
| C header | `sw/include/axi_mpu_regs.h` | 02-reg-model (PeakRDL) |
| SystemRDL | `regs/axi_mpu.rdl` | 02-reg-model |
| FuseSoC core | `aixsilicon_ip_axi_mpu.core` | 08-fusesoc-packager |
| 参数空间模型 | `model/parameter_space.yaml` | 19-param-space-verification |

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
