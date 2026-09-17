# PQC 加速器逻辑详细设计：寄存器字段行为（1）标识、能力与控制

> 本册表达"字段如何工作"（行为 Source of Intent）。**不含 offset/bit 表**——
> 字段结构由 `regs/pqc.rdl`（SystemRDL）作为结构 Source of Truth 承载。

## 标识与能力

### LLD.REG.PQC.ID_VERSION

<!-- LLD_REG_META
id: LLD.REG.PQC.ID_VERSION
register_ref: ID_VERSION
behavior: lock
sw_behavior: ro
hw_behavior: 复位值由综合期参数与 IP 版本决定；运行期不变
collision: hw_wins
update_timing: reset_only
reset_semantics: hard=综合期常量, soft=保持
req_ref:
- LRS.REG.PQC.ID.001
END_LLD_REG_META -->

### LLD.REG.PQC.CAP0

<!-- LLD_REG_META
id: LLD.REG.PQC.CAP0
register_ref: CAPABILITY0
behavior: lock
sw_behavior: ro
hw_behavior: 由 ENABLE_ALGO_MASK、NTT_LANES、SCA_LEVEL、ENABLE_HASH_ML_DSA 综合常量驱动
collision: hw_wins
update_timing: reset_only
reset_semantics: hard=综合期常量, soft=保持
req_ref:
- LRS.REG.PQC.ID.001
- LRS.CFG.PQC.ALGO_MASK.001
- LRS.CFG.PQC.SCA_LEVEL.001
END_LLD_REG_META -->

### LLD.REG.PQC.CAP1

<!-- LLD_REG_META
id: LLD.REG.PQC.CAP1
register_ref: CAPABILITY1
behavior: lock
sw_behavior: ro
hw_behavior: 由 LOCAL_SRAM_KIB、DMA_DATA_WIDTH、KEY_SLOT_NUM、ENABLE_PIO 综合常量驱动
collision: hw_wins
update_timing: reset_only
reset_semantics: hard=综合期常量, soft=保持
req_ref:
- LRS.REG.PQC.ID.001
- LRS.CFG.PQC.LOCAL_SRAM.001
- LRS.CFG.PQC.DMA_WIDTH.001
- LRS.CFG.PQC.KEY_SLOT.001
END_LLD_REG_META -->

## 控制

### LLD.REG.PQC.CTRL_ENABLE

<!-- LLD_REG_META
id: LLD.REG.PQC.CTRL_ENABLE
register_ref: CTRL.ENABLE
behavior: atomic
sw_behavior: rw
hw_behavior: 使能后从 DISABLED 进入 SELFTEST；自检通过后进入 IDLE
collision: sw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.CTRL.001
- LRS.RESET.PQC.COLD.001
END_LLD_REG_META -->

### LLD.REG.PQC.CTRL_ABORT

<!-- LLD_REG_META
id: LLD.REG.PQC.CTRL_ABORT
register_ref: CTRL.ABORT
behavior: atomic
sw_behavior: rw
hw_behavior: singlepulse 请求由 FE 锁存；在安全边界点停止当前命令，随后清零临时状态并回到 IDLE；脉冲后一拍自清
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.FUNC.PQC.CMD.007
END_LLD_REG_META -->

### LLD.REG.PQC.CTRL_ZEROIZE

<!-- LLD_REG_META
id: LLD.REG.PQC.CTRL_ZEROIZE
register_ref: CTRL.ZEROIZE
behavior: atomic
sw_behavior: rw
hw_behavior: singlepulse 请求由 fault_ctrl 独立锁存，不依赖请求位保持；内部擦除有界，外部排空超时不报成功
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
END_LLD_REG_META -->

### LLD.REG.PQC.CTRL_SELFTEST

<!-- LLD_REG_META
id: LLD.REG.PQC.CTRL_SELFTEST
register_ref: CTRL.SELF_TEST
behavior: atomic
sw_behavior: rw
hw_behavior: singlepulse 请求由 FE 锁存后触发 KAT；失败置 SELF_TEST_FAIL 并进入 LOCKED
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.RESET.PQC.COLD.001
END_LLD_REG_META -->

## 状态

### LLD.REG.PQC.STATUS

<!-- LLD_REG_META
id: LLD.REG.PQC.STATUS
register_ref: STATUS
behavior: hw_set
sw_behavior: ro
hw_behavior: IDLE/BUSY/DONE/ERROR/LOCKED 由顶层 FSM 直接驱动；LOCKED 由 fault_ctrl 置位
collision: hw_wins
update_timing: immediate
reset_semantics: hard=IDLE 编码, soft=IDLE 编码
req_ref:
- LRS.REG.PQC.STATUS.001
END_LLD_REG_META -->

## 命令与描述符（BUSY 锁定组）

### LLD.REG.PQC.COMMAND

<!-- LLD_REG_META
id: LLD.REG.PQC.COMMAND
register_ref: COMMAND
behavior: shadow
sw_behavior: rw
hw_behavior: 门铃时原子抓取；BUSY 期间 swwe 被 ~busy 关闭，值不变且返回 pslverr
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: hard=ABI版本1且其他字段0, soft=同hard
req_ref:
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.004
END_LLD_REG_META -->

### LLD.REG.PQC.DESC_ADDR

<!-- LLD_REG_META
id: LLD.REG.PQC.DESC_ADDR
register_ref: DESC_ADDR_LO_HI
behavior: shadow
sw_behavior: rw
hw_behavior: 写入后作为下一次门铃的描述符地址；抓到 shadow 后不再受软件影响
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.FUNC.PQC.CMD.002
END_LLD_REG_META -->

### LLD.REG.PQC.DOORBELL

<!-- LLD_REG_META
id: LLD.REG.PQC.DOORBELL
register_ref: DOORBELL
behavior: atomic
sw_behavior: rw
hw_behavior: 写 1 产生 singlepulse；FE 锁存提交身份后启动抓取，CSR 请求位下一拍自清；BUSY 时写返回 pslverr
collision: sw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.FUNC.PQC.CMD.006
END_LLD_REG_META -->

### LLD.REG.PQC.KEY_HANDLE

<!-- LLD_REG_META
id: LLD.REG.PQC.KEY_HANDLE
register_ref: KEY_HANDLE
behavior: shadow
sw_behavior: rw
hw_behavior: 门铃时抓取完整 generation/owner/slot；类型由可信元数据匹配算法和用途，不再占 handle 编码；不匹配返回配置错误
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.SEC.PQC.SLOT.003
END_LLD_REG_META -->

## 请求位与命令组的字段补充

CTRL.abort/zeroize/self_test 和 DOORBELL.doorbell 使用 SystemRDL singlepulse，
软件写 0 不产生请求，写 1 只在成功 APB 写事务后产生一个核心周期的请求，下一沿
自清。FE/FAULT 必须锁存该事件直到执行完成，禁止依赖软件位持续为 1。脉冲期间
寄存器存储值可为 1；后续正常 APB 读事务读回 0，读取不产生新请求。
CTRL.enable 是持续配置，通过 swwe 按 idle/权限策略保护，不使用 singlepulse。
多个控制位同次写入时 ZEROIZE 优先于 ABORT，SELF_TEST 只在无活动命令且未锁定时
接受；包装层拒绝非法组合时屏蔽整次 CSR 写入，不能一部分报错、一部分改变状态。

COMMAND 的 opcode/parameter_set/flags/abi 全部受 BUSY swwe 门控；不能只保护
低位命令字段。KEY_HANDLE 的 slot_id、owner、generation 同样全部锁定，句柄布局
遵循 HLD 固定的完整 handle，key_type 通过元数据查询而不是从句柄中截出。
门铃和配置写为单 APB 端口顺序事务；一旦门铃被接受，busy_pending 立即参与写保护，
不等 descriptor FETCH 实际发出才阻止后续配置写。

SRC0/SRC1 的地址和长度、CONTEXT_ADDR、ENTROPY_POLICY、DST0/DST1 的地址和容量、
COMPLETION_ADDR、TIMEOUT_HINT、DESCRIPTOR_CRC 均属于命令 shadow 组：idle 写入，
门铃整体锁存，busy 时字段值不变并返回 PSLVERR。CONTEXT_LEN 与 DESC_ADDR 两半
遵守相同规则；外部描述符路径不使用的 shadow 字段不得覆盖 DMA 抓取的已校验字段。
CONTEXT_LEN 宽度之外的保留位写入忽略；外部描述符中的越界长度仍由 FE 拒绝。

ERROR_CODE 的未定义高位为 RDL 间隙，读零写忽略；不得通过硬件 next 输入接出
未定义数据。所有生成视图在寄存器行为评审完成后由当前 RDL 再生，不能手改 CSR。

### LLD.REG.PQC.CONTEXT_LEN

<!-- LLD_REG_META
id: LLD.REG.PQC.CONTEXT_LEN
register_ref: CONTEXT_LEN
behavior: shadow
sw_behavior: rw
hw_behavior: 关键校验 0–255；越界返回配置错误且不访问秘密
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.FUNC.PQC.DSA_MESSAGE.001
END_LLD_REG_META -->

## 结果与错误

### LLD.REG.PQC.RESULT

<!-- LLD_REG_META
id: LLD.REG.PQC.RESULT
register_ref: RESULT
behavior: hw_set
sw_behavior: ro
hw_behavior: completion 发布时写入 verify_valid 与 completion tag；COMMIT 前保持旧值
collision: hw_wins
update_timing: commit
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.RESULT.001
END_LLD_REG_META -->

### LLD.REG.PQC.ERROR_CODE

<!-- LLD_REG_META
id: LLD.REG.PQC.ERROR_CODE
register_ref: ERROR_CODE
behavior: hw_set
sw_behavior: ro
hw_behavior: 仅在公开诊断分类间取值；不得由秘密值派生；KEM_DECAPS 不写有效性
collision: hw_wins
update_timing: immediate
reset_semantics: hard=0, soft=clear
req_ref:
- LRS.REG.PQC.ERRCODE.001
- LRS.FUNC.PQC.CMD.005
END_LLD_REG_META -->
