# Watchdog：DISPATCH 模块细化

<!-- LLD_MODULE_META
id: LLD.MOD.WATCHDOG.DISPATCH
name: dispatch
parent_ref: HLD.MOD.WATCHDOG.DISPATCH
hld_ref:
- HLD.MOD.WATCHDOG.DISPATCH
req_ref:
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
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
- LRS.FUNC.WATCHDOG.STA.001
- LRS.FUNC.WATCHDOG.STA.002
- LRS.FUNC.WATCHDOG.STA.003
- LRS.FUNC.WATCHDOG.STA.004
- LRS.FUNC.WATCHDOG.STA.005
- LRS.PERF.WATCHDOG.COMMAND.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: false
  suggested_name: watchdog_top
clock_domains:
- HLD.DOM.CLK.WATCHDOG.WDT
reset_domains:
- HLD.DOM.RST.WATCHDOG.POR_WDT
END_LLD_MODULE_META -->

两请求 req[0]=mailbox_available，req[1]=SUPPORT_HW_EVENT & hw_evt_valid。复用
aixsilicon:cbb:round_robin_arbiter:0.1.0，NUM_REQ=2、PC_IMPL=0、组合 grant，
GRANT_ACK_EN=0 时 grant_ack_i 不参与轮换；取消窗口将 CBB req_i 屏蔽为0，旁路完成取消，不更新公平性状态。
初次同时请求按 CBB 复位优先级，连续双请求交替；每个持续请求至多跨一个竞争授予。

选中软件源直接使用稳定邮箱，选中硬件源构造 SERVICE command、hardware=1，复制
channel/client/type/data/source，service_auth 由可信硬件桥合同成立。hw_evt_ready
只在实际硬件执行且无 warm/邮箱取消抢占时置1，valid&&ready 才消费一次。
目的通道有效时仅置一个 cmd_valid。无效硬件通道不能越界索引或影响任意有效通道。
计时/Deadline/完整性事件不需要 grant，仲裁不会延后这些事件。
