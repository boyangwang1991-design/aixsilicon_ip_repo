# PQC 加速器逻辑详细设计：寄存器字段行为（2）中断、告警、性能与 key slot

## 中断

### LLD.REG.PQC.INTR_STATE

<!-- LLD_REG_META
id: LLD.REG.PQC.INTR_STATE
register_ref: INTR_STATE
behavior: w1c
sw_behavior: rw1c
hw_behavior: hwset on DONE/ERROR/RNG_FAULT/TAMPER/SELF_TEST_FAIL 事件
collision: set_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_REG_META -->

同周期 HW set 与 SW W1C 冲突时 set 优先，保证事件不丢失。

### LLD.REG.PQC.INTR_ENABLE

<!-- LLD_REG_META
id: LLD.REG.PQC.INTR_ENABLE
register_ref: INTR_ENABLE
behavior: atomic
sw_behavior: rw
hw_behavior: 只屏蔽中断输出，不影响 INTR_STATE 置位
collision: sw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.INTR.001
- LRS.FUNC.PQC.CMD.008
END_LLD_REG_META -->

### LLD.REG.PQC.INTR_TEST

<!-- LLD_REG_META
id: LLD.REG.PQC.INTR_TEST
register_ref: INTR_TEST
behavior: atomic
sw_behavior: rw
hw_behavior: 每个 test 字段为 singlepulse，写 1 仅一拍置位对应 INTR_STATE，随后自清；不产生真实密码副作用
collision: sw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.INTR.001
END_LLD_REG_META -->

## 告警

### LLD.REG.PQC.ALERT_RECOVERABLE

<!-- LLD_REG_META
id: LLD.REG.PQC.ALERT_RECOVERABLE
register_ref: ALERT_RECOVERABLE
behavior: w1c
sw_behavior: rw1c
hw_behavior: hwset on recoverable 故障（如可纠正 ECC、单次 DMA retry）
collision: set_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.ALERT.001
END_LLD_REG_META -->

### LLD.REG.PQC.ALERT_FATAL

<!-- LLD_REG_META
id: LLD.REG.PQC.ALERT_FATAL
register_ref: ALERT_FATAL
behavior: lock
sw_behavior: rw1c
hw_behavior: hwset on fatal 故障（tamper、ECC UE、self-test fail）；置位后进入 LOCKED，
  密码命令被拒绝；需显式恢复流程才能退出
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.ALERT.001
- LRS.SEC.PQC.LOCK.001
END_LLD_REG_META -->

## 性能计数器

### LLD.REG.PQC.PERF_TOTAL

<!-- LLD_REG_META
id: LLD.REG.PQC.PERF_TOTAL
register_ref: PERF_TOTAL_CYCLES
behavior: atomic
sw_behavior: rw
hw_behavior: 使用显式 next/we 接收硬件累加值；idle 时通过 swwe 允许软件写 0 清零，busy 或非零写被抑制
collision: sw_wins
update_timing: idle_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.PERF.001
- LRS.DFX.PQC.PERFCNT.001
END_LLD_REG_META -->

### LLD.REG.PQC.PERF_SUB

<!-- LLD_REG_META
id: LLD.REG.PQC.PERF_SUB
register_ref: PERF_KECCAK_NTT_DMASTALL
behavior: atomic
sw_behavior: rw
hw_behavior: 分别通过 next/we 累加 Keccak cycles、NTT cycles 与 DMA stall；公开命令类型计数独立，idle 零写由 swwe 放行
collision: sw_wins
update_timing: idle_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.PERF.001
END_LLD_REG_META -->

生产策略下不提供签名尝试次数或秘密相关细粒度事件的读出口。

## Key slot 管理窗口

### LLD.REG.PQC.SLOT_CTRL

<!-- LLD_REG_META
id: LLD.REG.PQC.SLOT_CTRL
register_ref: KEY_SLOT_CTRL
behavior: lock
sw_behavior: rw
hw_behavior: 仅受特权/安全主体属性允许访问；普通主体访问返回 pslverr 并记录；debug
  解锁不改变可访问性
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.004
END_LLD_REG_META -->

### LLD.REG.PQC.SLOT_META

<!-- LLD_REG_META
id: LLD.REG.PQC.SLOT_META
register_ref: KEY_SLOT_META_WINDOW
behavior: hw_set
sw_behavior: ro
hw_behavior: 回读指定 slot 的 owner/domain/algorithm/parameter_set/usage/exportable/
  valid/version；不含私钥内容
collision: hw_wins
update_timing: immediate
reset_semantics: hard=invalid, soft=按策略
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.REG.PQC.SLOT.001
END_LLD_REG_META -->

### LLD.REG.PQC.SLOT_DESTROY

<!-- LLD_REG_META
id: LLD.REG.PQC.SLOT_DESTROY
register_ref: KEY_SLOT_CTRL.DESTROY
behavior: atomic
sw_behavior: rw
hw_behavior: 清零 slot 内容并递增 generation，使旧 handle 失效；操作中被引用时延迟到
  当前命令结束再加锁执行
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.002
END_LLD_REG_META -->

## Completion record

### LLD.REG.PQC.COMPLETION

<!-- LLD_REG_META
id: LLD.REG.PQC.COMPLETION
register_ref: COMPLETION_RECORD
behavior: hw_set
sw_behavior: ro
hw_behavior: 在 DMA 输出完成后写入 command_id/status/output 长度/verify_valid/
  error_info/cycles；随后才置 DONE
collision: hw_wins
update_timing: commit
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.COMPLETION.001
- LRS.FUNC.PQC.CMD.006
END_LLD_REG_META -->

## SW/HW 同拍冲突汇总

| SW Operation | HW Operation | Same Cycle Result |
|---|---|---|
| W1C on INTR_STATE | HW set event | HW set wins（事件不丢失） |
| W1C on ALERT_RECOVERABLE | HW set fault | HW set wins |
| RW on COMMAND/DESC/KEY_HANDLE/CONTEXT_LEN | BUSY assert | SW write blocked（swwe 关闭，pslverr，值不变） |
| RW on PERF | command running | SW write ignored，不能延后重放；HW next/we 正常更新 |
| RW on SLOT_DESTROY | slot referenced | destroy deferred until command end |
| RW on CTRL.ZEROIZE | fatal fault | HW wins（零化优先） |

## Configuration Activation

| 类别 | Activation |
|---|---|
| 标识/能力 | reset_only（综合常量） |
| COMMAND/DESC/KEY_HANDLE/CONTEXT_LEN | transaction_boundary（门铃抓取 shadow） |
| CTRL.enable | immediate（需 IDLE） |
| CTRL.abort/zeroize/self_test | immediate（安全收口） |
| INTR/ALERT | immediate + W1C |
| PERF | idle_boundary 清零 |
| KEY_SLOT_CTRL | immediate（受特权门控） |

## 字段完整性与结构交接

KEY_SLOT_CTRL 的 slot_index/key_type 保持配置；import_req/destroy_req/export_req/lock_req
为 singlepulse，只有覆盖该字段的有效写字节且写 1 才产生一次管理请求。KEYSLOT 必须
锁存请求和对应配置，等待中的请求不依赖 CSR 位保持。软件不能通过管理请求自行创建
可信 owner/domain/usage；导入仍须匹配专用 Key Manager 的认证头。


INTR_TEST 的五个字段分别 singlepulse；仅授权测试生命周期的成功 APB 写入触发，
不因请求位保持而连续重置 INTR_STATE。正常中断 state/enable 的独立语义不变。

PERF_TOTAL_CYCLES、PERF_KECCAK_CYCLES、PERF_NTT_CYCLES、PERF_DMA_STALL 和
PERF_CMD_COUNT 的全部字段均有硬件 next/we。更新由 FE 的公开事件计数逻辑产生，
饱和时保持最大值并产生一次 recoverable 事件；软件读取不清零。swwe 条件为 idle、
该写访问合法、对应有效写字节的数据全零；未选中字节不改变。非零写或 busy 写
不修改计数器，也不排队延后执行。一个字段同沿若 HW update 与合法 SW clear 冲突，
SW clear 优先；启动沿 busy_pending 抑制 SW clear，故不会丢失首拍计数。
所有 warm/功能复位按已定义的 CSR 功能复位清零，而不是借 hwclr 恢复其他字段的
非零复位值。生产生命周期的秘密相关细粒度计数始终读零，具体屏蔽由包装层完成。

KEY_SLOT_META 返回选中 slot 的 owner、algorithm、parameter_set、usage_mask、
exportable、valid、locked、version；KEY_SLOT_GEN 返回完整 generation，新增
KEY_SLOT_DOMAIN 返回 domain。它们都是安全管理窗口中的只读元数据，不是材料端口。
KEY_SLOT_MIRROR 只返回 owner/valid；不实现的 slot 索引返回零。所有镜像未定义位
由 RDL 间隙表达，不实例化可被硬件驱动的 reserved 字段。身份以一次管理快照
的同一版本为准，查询期间若撤销则 valid 清零；软件读回不能作为执行授权。

<!-- LLD_REG_META
id: LLD.REG.PQC.SLOT_DOMAIN
register_ref: KEY_SLOT_DOMAIN.domain
behavior: hw_set
sw_behavior: ro
hw_behavior: 受安全管理窗口保护，返回选中 slot 的可信 domain；非法索引或无效快照返回零
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=按授权元数据策略但材料保持无效
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.REG.PQC.SLOT.001
END_LLD_REG_META -->


### 告警事件连接补充（2026-09-18）

TOP 将工作 SRAM/WORKKEY 的不可纠正 ECC、生命周期门控后的 DFT ECC 注入、
tamper、自检失败和可纠正 ECC 分别连接到生成 CSR 的同名 `hwset`。
CSR 保持 RDL 定义的 W1C、硬件置位优先；软件清除事件历史不改变独立 fault lock。
本次没有将聚合 fatal 信号错误映射成所有分项位；其余 integrity/retry/perf 事件的
完整归因和控制集成仍是专项义务。真实 tamper 的 idle UVM 检查两次有界清除 ACK、
W1C 与锁定保持，不代表执行中故障注入或秘密内容擦除验收。
