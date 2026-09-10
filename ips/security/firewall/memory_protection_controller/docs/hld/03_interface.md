# AXI Memory Protection Unit — HLD 接口

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 外部接口

### 1.1 S_AXI 从接口

#### HLD.IF.EXT.AXI_MPU.S_AXI AXI4 从接口

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.AXI_MPU.S_AXI
name: s_axi
scope: external
protocol: AXI4
role: slave
owner_module: HLD.MOD.L1.AXI_MPU.TOP
clock_domain: CLK_SYS
reset_domain: RST_SYS_N
signal_groups:
  - name: AR channel (ARADDR/ARPROT/ARID/ARBURST/ARLEN/ARSIZE/ARVALID/ARREADY)
  - name: R channel (RID/RDATA/RRESP/RLAST/RVALID/RREADY)
  - name: AW channel (AWADDR/AWPROT/AWID/AWBURST/AWLEN/AWSIZE/AWVALID/AWREADY)
  - name: W channel (WDATA/WSTRB/WLAST/WVALID/WREADY)
  - name: B channel (BID/BRESP/BVALID/BREADY)
req_ref:
  - LRS.INTF.AXI_MPU.AXI_SLAVE.001
  - LRS.INTF.AXI_MPU.AXI_SLAVE.002
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

---

### 1.2 M_AXI 主接口

#### HLD.IF.EXT.AXI_MPU.M_AXI AXI4 主接口

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.AXI_MPU.M_AXI
name: m_axi
scope: external
protocol: AXI4
role: master
owner_module: HLD.MOD.L1.AXI_MPU.TOP
clock_domain: CLK_SYS
reset_domain: RST_SYS_N
signal_groups:
  - name: AR channel (forward AR)
  - name: R channel (return R)
  - name: AW channel (forward AW)
  - name: W channel (forward W)
  - name: B channel (return B)
req_ref:
  - LRS.INTF.AXI_MPU.AXI_MASTER.001
  - LRS.INTF.AXI_MPU.AXI_SLAVE.002
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

---

### 1.3 APB4 配置接口

#### HLD.IF.EXT.AXI_MPU.APB4 APB4 配置接口

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.AXI_MPU.APB4
name: apb4_cfg
scope: external
protocol: APB4
role: slave
owner_module: HLD.MOD.L1.AXI_MPU.REG_FILE
clock_domain: CLK_SYS
reset_domain: RST_SYS_N
signal_groups:
  - name: PADDR/PSEL/PENABLE/PWRITE/PWDATA/PSTRB/PPROT/PRDATA/PREADY/PSLVERR
req_ref:
  - LRS.INTF.AXI_MPU.APB_CFG.001
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

---

### 1.4 IRQ 中断接口

#### HLD.IF.EXT.AXI_MPU.IRQ Violation 中断接口

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.AXI_MPU.IRQ
name: irq
scope: external
protocol: level_irq
role: output
owner_module: HLD.MOD.L1.AXI_MPU.VIOLATION
clock_domain: CLK_SYS
reset_domain: RST_SYS_N
signal_groups:
  - name: irq (level, sticky, W1C clear)
req_ref:
  - LRS.INTF.AXI_MPU.IRQ.001
  - LRS.FUNC.AXI_MPU.IRQ.001
applicability:
  expr: "has_irq == true"
END_HLD_INTERFACE_META -->

---

## 2. 内部接口

内部接口（Region Table / Master Attr / Request Context / Permission Result /
Write Decision Queue）在 [02_functional.md](02_functional.md) §3.5 定义。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
