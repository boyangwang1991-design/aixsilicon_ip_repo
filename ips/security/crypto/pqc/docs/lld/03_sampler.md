# PQC SAMPLER 流接口与执行控制（draft）

### LLD.MOD.PQC.SAMPLER

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.SAMPLER
name: pqc_sampler
parent_ref: HLD.MOD.PQC.SAMPLER
hld_ref:
- HLD.MOD.PQC.SAMPLER
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_sampler
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 模块内职责划分

保留一个 SAMPLER RTL 边界，内部划分 squeeze 解包、候选映射、秘密顺序扫描和结果
提交四个对象。KECCAK 拥有 XOF 状态，SAMPLER 不重建 SHAKE；CODEC 提供 masked
比较/选择/转换 gadget，SRAM 提供 scratch 与结果页。公开矩阵拒绝和秘密拒绝不得
共用会暴露秘密接受次数的地址/完成控制。秘密路径见 `03_sampler_secret.md`。

入口锁存 mode/pset/domain/epoch/primitive_id、目的 allocation_id、XOF context 和
公开预算；不能在运行中读取变化的 eta/tau/gamma1。非法组合报告格式错误，禁止启动。
KEM CBD 仅 eta=2/3，DSA ExpandS 仅 eta=2/4，ExpandMask 仅 gamma1=2^17/2^19，
SampleInBall 仅 tau=39/49/60，并与 pset 相符。单事务，完成 valid 保持至匹配 ready；
旧 sticky done 不能完成下一次请求。取消高于输入/输出握手，旧 epoch 响应不写结果。

## 输入缓存、位序和续块

`LLD.BUF.PQC.SAMPLER.SQZ` 是 64×64-bit 逻辑缓存，Level 2 两个物理 share 域独立
存储，不能用同一单域 FIFO 时分保存两 share；公开流只用公开域。FIFO 的有效字节
数/上下文/epoch 是旁带，整 beat 握手一次才入队，不把末 beat 未使用字节作为下一事务。
现有字节宽 RTL 是待替换接口：64-bit beat 先按低字节解包，再按每字节低位优先消费。
FIFO 两域和解包寄存器必须支持实际擦除，不能只复位读写指针。

候选 bit reservoir 采用 32 bit/域，valid_bits[5:0]；每次最多追加一个字节，只有
valid_bits < need_bits 且有一个完整字节可用时才追加。最大 need_bits=24，追加前
至多 23 bit、追加后至多 31 bit，无溢出。追加和提取分两个周期，不在提取沿误拉 ready
丢字节；候选/结果 stall 时保存 reservoir、pending candidate 和 token。

块尾只申请同 context 的续块，不清 reservoir 或重置候选相位；命令终止才丢弃余位。
输入 underflow 等待，不输出零占位。SHAKE 的 rate 边界不等于系数或候选边界。
事务最终消费字节数返回引擎用于 context 退休，不把 overfetch 后的字节流交给其它种子。

| mode | 候选解包及映射 | 退出条件 |
|---|---|---|
| KEM uniform | 三字节拆两个 12-bit 候选，按先低后高顺序取小于 3329 者 | 第 256 次系数写回确认 |
| DSA ExpandA | 每三字节取低 23 bit，小于 8380417 者接受 | 第 256 次系数写回确认 |
| KEM CBD | 连续 2eta bit 的两组 popcount 之差，存为模 q residue | 恰好消费 64eta B，提交 256 系数 |
| DSA ExpandMask | 每 18/20 bit 得 v，输出 gamma1-v 的 residue | 恰好 576/640 B，提交 256 系数 |
| DSA ExpandS | 低/高 nibble 顺序；eta=2 接受 <15 并模 5 映射，eta=4 接受 <9 | 固定候选扫描后统一检查 |
| DSA SampleInBall | 先取 8 B signs，随后逐字节拒绝/条件交换 | 固定候选扫描后统一检查 |

映射依据 [FIPS 203](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf) 和
[FIPS 204](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf) 的采样算法；
固定预算、两遍扫描和周期分配是本实现的工程设计，不能当作标准的原生实现。

KEM 三字节组的第二候选需独立 pending 槽：第一候选写回后才处理第二候选，不能
因背压丢失或重排。若第一候选恰为第 256 项，丢弃第二候选，不能越界写 index=256。
ExpandA 必须消耗全部 24 bit，再屏蔽最高 bit；不能连续抽取 23 bit 导致后续错位。
CBD 和 ExpandMask 没有秘密接受分支，但 Level 2 的 popcount/减法/符号到 residue
转换仍需 masked gadget；原有未掩码算术不能直接扩成两份便宣称安全。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.SAMPLER.STREAM
module_ref: LLD.MOD.PQC.SAMPLER
input_width: 64
output_width: 32
operators: [lsb_byte_unpack, bounded_bit_reservoir, ordered_candidate_pair, canonical_residue_mapping]
representation: public_or_two_share_stream_to_coefficient
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 执行状态和提交

<!-- LLD_FSM_META
id: LLD.FSM.PQC.SAMPLER.EXECUTE
module_ref: LLD.MOD.PQC.SAMPLER
encoding: onehot
reset_state: CLEAR
states: [CLEAR, IDLE, INIT, FETCH, MAP, SCAN_READ, SCAN_WRITE, STORE, RESULT, FAIL, LOCKED]
illegal_state_handling: fatal
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
transitions:
- {source: CLEAR, destination: IDLE, condition: local_wipe_and_cancel_ack_and_clear_deasserted}
- {source: CLEAR, destination: LOCKED, condition: clear_timeout_or_fatal_latched}
- {source: IDLE, destination: INIT, condition: valid_command_fire}
- {source: IDLE, destination: FAIL, condition: invalid_command_fire}
- {source: INIT, destination: FETCH, condition: scratch_initialized_and_context_ready}
- {source: FETCH, destination: MAP, condition: full_candidate_available}
- {source: MAP, destination: FETCH, condition: public_rejection}
- {source: MAP, destination: STORE, condition: public_accepted_or_fixed_length_result_ready}
- {source: MAP, destination: SCAN_READ, condition: secret_rejection_mode_candidate_mapped}
- {source: SCAN_READ, destination: SCAN_WRITE, condition: all_256_public_addresses_read_and_gadget_results_ready}
- {source: SCAN_WRITE, destination: FETCH, condition: scan_writeback_complete_and_more_budget_candidates}
- {source: SCAN_WRITE, destination: STORE, condition: final_budget_candidate_completed}
- {source: STORE, destination: FETCH, condition: direct_mode_nonfinal_store_ack}
- {source: STORE, destination: RESULT, condition: all_256_stores_ack_and_no_budget_failure}
- {source: STORE, destination: FAIL, condition: all_256_stores_ack_and_budget_failure}
- {source: RESULT, destination: CLEAR, condition: matching_result_ready}
- {source: FAIL, destination: CLEAR, condition: error_ack_or_clear}
- {source: INIT, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: FETCH, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: MAP, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: SCAN_READ, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: SCAN_WRITE, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: STORE, destination: CLEAR, condition: cancel_or_fault_priority}
- {source: RESULT, destination: CLEAR, condition: cancel_or_fault_priority}
END_LLD_FSM_META -->

未列条件自环；STORE 在秘密拒绝模式中按公开 index 遍历全部 256 项，而非返回 FETCH。
内存写 valid 保持至 ready，地址/数据/域/身份稳定；游标只在写确认后推进。
最终 RESULT 需要全部写响应和页标签提交确认，不能用第 256 个请求发出替代完成。
失败的部分页保持 FILLING，绝不发布 VALID；失败清除后由 SRAM 回收。SRAM 错误、
token 错误、FIFO 下溢伪读、计数奇偶错误、超时均 fault→CLEAR，不允许继续补采样。
公开矩阵拒绝的运行量可依公开 seed 变化，watchdog 属系统错误，不能输出不足 256 项。

复位低有效异步置位、CORE 同步释放，先 CLEAR。清除屏蔽新输入与写请求，已接受
写事务必须真实排空；擦除 reservoir/pending/signs/share 保持槽及 SQZ FIFO 全深度，
双域同时逐地址擦除 64 个条目，至少 64 个清除写周期，再等 SRAM/context/gadget ack。
计数/地址/token 全部失效；clear_done 不能只看 FSM 回 IDLE。LOCKED 持续排空和清除。

## 实现与待闭环事项

P0 `rtl/pqc_sampler.sv`：替换无身份字节口、裸 secret-index ball 数组访问、秘密拒绝
驱动的写地址/时延、sticky done；补清除 ack、参数错误和 masked gadget。
`LLD.BUF.PQC.SAMPLER.SQZ` 尚不是现有 RTL 中已实现的 FIFO。共享缓存复用方案必须
证明双域擦除与预算，不能直接实例化仅复位指针的 FIFO 来储存秘密。
固定候选和流序检查为设计模型；完整 gadget 延迟/随机清单、sign 尝试预算及 RTL
功能/泄漏证据未闭环，G2 保持 open。公开流 datapath 与秘密扫描分别可独立验证，
本轮不新增缺少接口合同的空子模块。

## byte 接口过渡实现

现有 byte RTL 已增加 mode/domain 与 eta/tau/gamma1 的接受前校验；错误命令不接收
squeeze、不请求存储写，并返回 done 与 op_error，TOP 将错误交给 FE 收尾。
错误保持到下一次接受 start 或 zeroize。冷复位与 zeroize 都清 SampleInBall 的
256 项本地数组；取消同拍关闭 ready、mem_req、mem_we、done。该修正不替代上文
双 share 流接口、固定预算秘密扫描和带 token 的结果协议，仍属过渡实现。
