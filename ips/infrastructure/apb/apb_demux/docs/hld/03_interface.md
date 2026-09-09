# APB Demux — HLD 接口

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 接口概览

| 接口 | 方向 | 协议 | 角色 | 数量 |
|------|------|------|------|------|
| 上游 APB | Slave | APB3/APB4 | slave | 1 |
| 下游 APB | Master | APB3/APB4 | master | N |

## 2. 外部接口

### 2.1 上游 APB 从接口

#### HLD.IF.EXT.APB_DEMUX.UPSTREAM 上游 APB Slave 接口

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_DEMUX.UPSTREAM
name: s_apb
scope: external
protocol: APB4
role: slave
owner_module: HLD.MOD.L1.APB_DEMUX.TOP
clock_domain: CLK_APB
reset_domain: RST_APB_N
req_ref:
  - LRS.INTF.APB_DEMUX.01.001
  - LRS.INTF.APB_DEMUX.01.002
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

##### 需求描述

1. 上游 APB Slave-facing 接口：`PCLK`、`PRESETn`、`PADDR`、`PSEL`、
   `PENABLE`、`PWRITE`、`PWDATA`、`PRDATA`、`PREADY`、`PSLVERR`。
2. APB4 额外：`PSTRB`、`PPROT`。

---

### 2.2 下游 APB 主接口

#### HLD.IF.EXT.APB_DEMUX.DOWNSTREAM 下游 APB Master 接口组

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.APB_DEMUX.DOWNSTREAM
name: m_apb[N]
scope: external
protocol: APB4
role: master
owner_module: HLD.MOD.L1.APB_DEMUX.TOP
clock_domain: CLK_APB
reset_domain: RST_APB_N
req_ref:
  - LRS.INTF.APB_DEMUX.02.001
  - LRS.INTF.APB_DEMUX.02.002
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

##### 需求描述

1. 每个下游端口 APB Master-facing 接口：`M_PADDR[i]`、`M_PSEL[i]`、
   `M_PENABLE[i]`、`M_PWRITE[i]`、`M_PWDATA[i]`、`M_PRDATA[i]`、
   `M_PREADY[i]`、`M_PSLVERR[i]`，`i = 0...NUM_SLAVES-1`。
2. APB4 额外：`M_PSTRB[i]`、`M_PPROT[i]`。

---

## 3. 内部接口

### 3.1 内部数据通路（组合）

#### HLD.IF.INT.APB_DEMUX.DECODE_HIT 译码命中向量

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_DEMUX.DECODE_HIT
name: hit[N]
scope: internal
protocol: none
role: internal
owner_module: HLD.MOD.L1.APB_DEMUX.DECODE
clock_domain: CLK_APB
reset_domain: RST_APB_N
req_ref:
  - LRS.FUNC.APB_DEMUX.01.003
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

##### 需求描述

1. `hit[N]` 组合译码命中向量，供 PSEL 生成与错误检测使用。

---

#### HLD.IF.INT.APB_DEMUX.RESP_MUX 响应 mux 输入组

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_DEMUX.RESP_MUX
name: resp_in[N]
scope: internal
protocol: none
role: internal
owner_module: HLD.MOD.L1.APB_DEMUX.ROUTE
clock_domain: CLK_APB
reset_domain: RST_APB_N
req_ref:
  - LRS.FUNC.APB_DEMUX.04.001
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

##### 需求描述

1. N 个下游 `PRDATA/PREADY/PSLVERR` 响应组，供响应 mux 选择。

---

### 3.3 错误路径接口

#### HLD.IF.INT.APB_DEMUX.ERROR_PATH 错误响应接口

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.APB_DEMUX.ERROR_PATH
name: error_path
scope: internal
protocol: none
role: internal
owner_module: HLD.MOD.L1.APB_DEMUX.ERR
clock_domain: CLK_APB
reset_domain: RST_APB_N
req_ref:
  - LRS.FUNC.APB_DEMUX.05.002
  - LRS.FUNC.APB_DEMUX.05.003
applicability:
  expr: "true"
END_HLD_INTERFACE_META -->

##### 需求描述

1. Decode Miss / Timeout 错误响应路径：返回 `PREADY=1, PSLVERR=1` 并立即结束 transaction。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
