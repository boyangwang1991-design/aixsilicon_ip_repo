# CSR 微设计

<!-- LLD_MODULE_META
id: LLD.MOD.APB_SECURE_DEMUX.CSR
name: csr
hld_ref:
- HLD.MOD.APB_SECURE_DEMUX.CSR
req_ref:
- LRS.REG.APB_SECURE_DEMUX.CSR.00101
- LRS.REG.APB_SECURE_DEMUX.CSR.00102
- LRS.REG.APB_SECURE_DEMUX.CSR.002
- LRS.REG.APB_SECURE_DEMUX.CSR.00301
- LRS.REG.APB_SECURE_DEMUX.CSR.00302
- LRS.REG.APB_SECURE_DEMUX.CSR.00401
- LRS.REG.APB_SECURE_DEMUX.CSR.00402
- LRS.REG.APB_SECURE_DEMUX.CSR.005
- LRS.REG.APB_SECURE_DEMUX.CSR.00601
- LRS.REG.APB_SECURE_DEMUX.CSR.00602
- LRS.REG.APB_SECURE_DEMUX.CSR.007
- LRS.REG.APB_SECURE_DEMUX.CSR.008
- LRS.REG.APB_SECURE_DEMUX.AUTHORIZATION.005
- LRS.REG.APB_SECURE_DEMUX.MAP.006
objects:
- LLD.DP.APB_SECURE_DEMUX.CSR
rtl_intent:
  separate_module: true
  suggested_name: apb_secure_demux_csr
clock_domains:
- CLK_PCLK
reset_domains:
- RST_PRESET_N
END_LLD_MODULE_META -->

## 生成器接口与安全门控

使用 PeakRDL 原生 apb4-flat，关闭 request/readback retiming。该适配器在 SETUP 末沿采样 PSEL，ACCESS 周期产生 decoded request；所有 external 状态 owner 必须组合 ack，不能再插等待。CSR 原生 APB 接口只看到已经通过总译码、管理/公开读、对齐和全字节选通检查的请求。INTR_TEST、DFX 区和端口 DFX 统计额外经过硬件授权。功能裁剪先判断授权后报告未实现，避免泄露敏感寄存器存在性。

结构存在性/访问类型由 SystemRDL 及其生成译码决定，不能手写第二套地址 case。参数化实例由结构 owner 生成固定槽位的 RDL视图；wrapper 只连接生成的命名字段/选通信号与行为 owner。读保留位为零，写保留位忽略；命令有效位之外的保留位也忽略。

外部字段请求表示解码选中，不直接触发特殊状态写。统一 final_accept = LOCAL && upstream_ACCESS && precheck_ok && generated_access_ok && lock_ok && command_ok && integrity_ok；所有 state owner 仅在完成边沿接受 final_accept。拒绝时 CSR 模块仍内部 acknowledge 已采样的请求以释放 is_active，但命令不交付给 owner，上游返回主错误且读零。

SETUP 已获授权但 ACCESS 撤销 DFX 授权时，重新检查当前 dfx_authorized_i，返回 CFG_UNAUTHORIZED；同时清除尚未触发武装。普通 MASTERID/PPROT 来自捕获上下文，稳定性由输入协议约束。所有读请求不得作为命令执行，不能把 external rd_req 误用为 FIFO_POP。

## 错误分类与提交诊断

总译码先于 CSR 检查。CSR 主错误依次为授权、对齐、写选通、存在性、读写类型、锁、命令参数、完整性。即使多个条件同时失败，仅产生一条总线失败候选。

COMMIT_STATUS 另有 commit_attempt 信号：仅唯一 CSR、管理授权与基本检查通过且选中 COMMIT_MASK 写时有效。此时即使锁/命令/完整性导致 final_accept=0，也更新提交诊断。诊断顺序独立为非法掩码、全局锁、最低被选锁端口、完整性，成功为 LAST_OK。未授权/未对齐/非法选通不更新该诊断。

空 FIFO POP 写命令检查沿前队列是否为空（包括写零；CR-002规定空FIFO的POP为命令错误）；非空队列写零无弹出；FIFO=0 POP/HEAD 未实现，FIFO_STATUS 仍可读。所有动态拒绝都不能改变目标寄存器，审计状态变化除外。保留位不生成存储。

## 生成接口验收阻断点

必须对实际 exporter 输出检查组合 ack/无额外等待、bad-address 与 bad-rw 错误区分、external register 数据回传及完成门控；不能仅凭模板推断生成 RTL 合同满足。若原生接口无法满足首 ACCESS，回本分册修订方案并重开评审，不修改生成 RTL。
<!-- LLD_DATAPATH_META
id: LLD.DP.APB_SECURE_DEMUX.CSR
module_ref: LLD.MOD.APB_SECURE_DEMUX.CSR
operation: 管理授权先于地址存在性判断；公开身份读仅覆盖允许的信息窗口。检查选通、类型、锁和命令，分发唯一完成时生效的控制操作。寄存器结构由 SystemRDL 生成。
latency: 组合判定；状态仅在 pclk 完成/事件边沿更新
req_ref:
- LRS.REG.APB_SECURE_DEMUX.CSR.00101
- LRS.REG.APB_SECURE_DEMUX.CSR.00102
- LRS.REG.APB_SECURE_DEMUX.CSR.002
- LRS.REG.APB_SECURE_DEMUX.CSR.00301
- LRS.REG.APB_SECURE_DEMUX.CSR.00302
- LRS.REG.APB_SECURE_DEMUX.CSR.00401
- LRS.REG.APB_SECURE_DEMUX.CSR.00402
- LRS.REG.APB_SECURE_DEMUX.CSR.005
- LRS.REG.APB_SECURE_DEMUX.CSR.00601
- LRS.REG.APB_SECURE_DEMUX.CSR.00602
- LRS.REG.APB_SECURE_DEMUX.CSR.007
- LRS.REG.APB_SECURE_DEMUX.CSR.008
- LRS.REG.APB_SECURE_DEMUX.AUTHORIZATION.005
- LRS.REG.APB_SECURE_DEMUX.MAP.006
END_LLD_DATAPATH_META -->
