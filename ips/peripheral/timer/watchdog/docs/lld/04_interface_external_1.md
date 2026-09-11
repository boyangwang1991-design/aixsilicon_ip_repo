# Watchdog：外部信号接口

## APB

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.APB
owner_module: LLD.MOD.WATCHDOG.BUS
hld_ref:
- HLD.IF.EXT.WATCHDOG.APB
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.PORTS.001
- LRS.REG.WATCHDOG.ACCESS.001
protocol: APB4
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
applicability:
  expr: 'true'
signals:
- name: PSEL/PENABLE/PWRITE
  width: 1 each
  direction: in
  stability: SETUP/ACCESS期间按APB保持
- name: PADDR
  width: '15'
  direction: in
  stability: 字节地址，ACCESS完成前稳定
- name: PWDATA
  width: '32'
  direction: in
  stability: 写负载稳定
- name: PSTRB
  width: '4'
  direction: in
  stability: 写必须全1；读忽略
- name: PPROT
  width: '3'
  direction: in
  stability: 属性稳定，不用于生成可信授权
- name: PRDATA
  width: '32'
  direction: out
  stability: 成功读完成边沿有效，错误读0
- name: PREADY/PSLVERR
  width: 1 each
  direction: out
  stability: ACCESS完成采样；最多2 pclk
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| PSEL/PENABLE/PWRITE | 1 each | in | SETUP/ACCESS期间按APB保持 |
| PADDR | 15 | in | 字节地址，ACCESS完成前稳定 |
| PWDATA | 32 | in | 写负载稳定 |
| PSTRB | 4 | in | 写必须全1；读忽略 |
| PPROT | 3 | in | 属性稳定，不用于生成可信授权 |
| PRDATA | 32 | out | 成功读完成边沿有效，错误读0 |
| PREADY/PSLVERR | 1 each | out | ACCESS完成采样；最多2 pclk |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## AUTH

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.AUTH
owner_module: LLD.MOD.WATCHDOG.BUS
hld_ref:
- HLD.IF.EXT.WATCHDOG.AUTH
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.SEC.WATCHDOG.AUTH.001
protocol: trusted_sideband
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
applicability:
  expr: 'true'
signals:
- name: access_source_i
  width: SOURCE_WIDTH
  direction: in
  stability: 随APB稳定并捕获
- name: cfg_auth_i/service_auth_i/diag_auth_i
  width: 1 each
  direction: in
  stability: 独立可信授权，拒绝不执行
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| access_source_i | SOURCE_WIDTH | in | 随APB稳定并捕获 |
| cfg_auth_i/service_auth_i/diag_auth_i | 1 each | in | 独立可信授权，拒绝不执行 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

## APB_CLOCK_RESET

<!-- LLD_INTERFACE_META
id: LLD.IF.WATCHDOG.EXTERNAL.APB_CLOCK_RESET
owner_module: LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.IF.EXT.WATCHDOG.APB_CLOCK_RESET
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
protocol: clock_reset
clock_domain: HLD.DOM.CLK.WATCHDOG.APB
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
applicability:
  expr: 'true'
signals:
- name: pclk
  width: '1'
  direction: in
  stability: APB上升沿时钟
- name: preset_n
  width: '1'
  direction: in
  stability: 接口低有效，异步置位同步释放
END_LLD_INTERFACE_META -->

| 信号/逻辑对象 | 宽度 | 方向 | 采样和稳定规则 |
|---|---|---|---|
| pclk | 1 | in | APB上升沿时钟 |
| preset_n | 1 | in | 接口低有效，异步置位同步释放 |

未接收请求无副作用；保持型状态不依赖接收者ready。跨域多位字段采用所属握手的稳定窗口，不能另加逐位同步。

