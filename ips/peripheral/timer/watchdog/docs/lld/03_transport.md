# Watchdog：TRANSPORT 模块细化

<!-- LLD_MODULE_META
id: LLD.MOD.WATCHDOG.TRANSPORT
name: transport
parent_ref: HLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.MOD.WATCHDOG.TRANSPORT
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.ACCESS.001
- LRS.REG.WATCHDOG.IDENTITY.001
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
- LRS.PERF.WATCHDOG.COMMAND.001
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
- LRS.SEC.WATCHDOG.AUTH.001
- LRS.CONS.WATCHDOG.SOFTWARE.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: false
  suggested_name: watchdog_top
clock_domains:
- HLD.DOM.CLK.WATCHDOG.APB
- HLD.DOM.CLK.WATCHDOG.WDT
reset_domains:
- HLD.DOM.RST.WATCHDOG.POR_APB
- HLD.DOM.RST.WATCHDOG.POR_WDT
END_LLD_MODULE_META -->

单在途 req_toggle/ack_toggle 邮箱，APB 捕获完整 command/config 时翻转 req 并置
busy，issued_seq 加一、EXEC_DONE 清零；负载与奇偶校验一直保持至返回确认。请求
经 S 级 WDT 同步，末级不等 ack 时可见；执行/取消同一边沿锁存 result、snapshot、
ack=req。ack 经 S 级 APB 同步后，在下一接收边沿统一发布 DONE 并释放 busy。

接收新命令时根据旧 busy 判断，完成与新写同拍仍忙拒绝，避免源负载与目的读窗口
重叠；下一 APB 事务才可复用槽位。busy=0 时不再响应旧 ack，最多完成一次。
preset 不改变 toggle、同步链、busy、序号及镜像。POR 同时初始化 req=ack=0。

warm 在 WDT 可见请求上优先于仲裁，产生 CANCELED_RESET，不发 channel cmd_valid；
已执行等待应答的事务只发布原结果。同步链内请求按与请求同深度的取消标记对齐，详见 transport_cdc_2 分册的 E0..E(S+1)
推导；不得单独改变任一链深度，否则会造成漏取消或与新请求误关联。
