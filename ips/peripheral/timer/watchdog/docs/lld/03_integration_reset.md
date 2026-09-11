# Watchdog：域复位与初始状态

## POR_APB

<!-- LLD_RESET_META
id: LLD.RST.WATCHDOG.POR_APB
module_ref: LLD.MOD.WATCHDOG.INTEGRATION
reset_domain: HLD.DOM.RST.WATCHDOG.POR_APB
type: async_assert_sync_release
affected_objects:
- LLD.MOD.WATCHDOG.BUS
- LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.MOD.WATCHDOG.INTEGRATION
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
applicability:
  expr: 'true'
END_LLD_RESET_META -->

POR异步置低，pclk上升沿移入1，S级后释放prst_n。邮箱req/seq/busy/done/snap_valid/
err_req/ack同步链归此域：req=ack初值0，反码1，busy/done/序号/valid0，镜像和负载0。
仅POR清这些寄存器；preset期间已收请求继续执行并返回，软件重启查询保留完成记录。

## APB_INTERFACE

<!-- LLD_RESET_META
id: LLD.RST.WATCHDOG.APB_INTERFACE
module_ref: LLD.MOD.WATCHDOG.INTEGRATION
reset_domain: HLD.DOM.RST.WATCHDOG.APB_INTERFACE
type: async_assert_sync_release
affected_objects:
- LLD.MOD.WATCHDOG.BUS
- LLD.MOD.WATCHDOG.INTEGRATION
hld_ref:
- HLD.MOD.WATCHDOG.INTEGRATION
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
applicability:
  expr: 'true'
END_LLD_RESET_META -->

por_n & preset_n异步置低，pclk的S级释放链与prst_n相与形成apb_rst_n。staging恢复
DEFAULT_CFG、选择器0、APB事务和IRQ/状态同步输出清0。preset在APB接受前取消未
完成总线操作，在接受后不得复位保留邮箱。解除后从WDT保留事件重新同步IRQ。

## POR_WDT

<!-- LLD_RESET_META
id: LLD.RST.WATCHDOG.POR_WDT
module_ref: LLD.MOD.WATCHDOG.INTEGRATION
reset_domain: HLD.DOM.RST.WATCHDOG.POR_WDT
type: async_assert_sync_release
affected_objects:
- LLD.MOD.WATCHDOG.CHANNEL
- LLD.MOD.WATCHDOG.SAFETY
- LLD.MOD.WATCHDOG.DISPATCH
- LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.MOD.WATCHDOG.INTEGRATION
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
applicability:
  expr: 'true'
END_LLD_RESET_META -->

POR在WDT域S级释放，req同步/ack/取消标记/错误ack初始化0，仲裁复位按CBB合同。
通道active=DEFAULT_CFG，硬锁按参数，其余锁0，C/D/历史/恢复/序列/统计0，影子为
对应反码。首个可用边沿初始化token并建立AUTO_START周期起点；此边沿不增加年龄。
检查从主影子均初始化后的第一个正常边沿有效，禁止超过S+2的可控屏蔽。
warm/local只走有优先级的状态事件，不复位任何toggle。

