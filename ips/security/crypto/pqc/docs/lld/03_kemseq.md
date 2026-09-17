# PQC KEMSEQ 命令与原语控制（draft）

### LLD.MOD.PQC.KEMSEQ

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KEMSEQ
name: pqc_kem_seq
parent_ref: HLD.MOD.PQC.KEMSEQ
hld_ref:
- HLD.MOD.PQC.KEMSEQ
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.002
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x7'
rtl_intent:
  separate_module: true
  suggested_name: pqc_kem_seq
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 职责与入口

本模块拥有操作 PC、公开循环计数和 primitive scoreboard。POLY/KECCAK/SAMPLER/CODEC
拥有运算状态；SRAM 拥有页标签；WORKKEY 拥有私钥材料；FE 拥有系统完成与 DMA 提交。
控制和比较数据通路留在一个 RTL 模块内，但使用独立寄存器组和使能；算法子程序是
微程序入口，不制造 KeyGen/Encaps/Decaps 三套计算模块。比较结果不能成为控制输入。

入口仅在 IDLE 接受 FE 的 valid/ready，沿锁存 op、pset、epoch、授权和页描述符。
rank 只允许 0/1/2，对应 k=2/3/4；其它编码是公开格式错误，不默认进入 Decaps。
接受后不再读取可变 CSR，输出长度由锁存 pset 查表，不能使用调用者 ct_bytes 作循环界。
长度、公开 key canonicality、私钥长度与 H(ek) 完整性检查必须通过后才允许秘密执行。
WORKKEY 已检查的私钥属性须绑定相同 epoch/grant；不能用旧命令的检查结果跳过当前校验。

| pset | k | eta1 / eta2 | du / dv | ek B | dk B | ct B |
|---|---:|---|---|---:|---:|---:|
| ML-KEM-512 | 2 | 3 / 2 | 10 / 4 | 800 | 1632 | 768 |
| ML-KEM-768 | 3 | 2 / 2 | 10 / 4 | 1184 | 2400 | 1088 |
| ML-KEM-1024 | 4 | 2 / 2 | 11 / 5 | 1568 | 3168 | 1568 |

规范依赖依据 [FIPS 203 §5–7](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf)。
本实现的串行发射、局部存储归属和握手为工程选择，不是规范给出的硬件时序。

## 原语事务与调度寄存器

一次仅有一个 KEM 原语未退休，先采用可审核串行顺序；未来重叠必须证明 bank、随机
配额与 token 无冲突并重新核算性能。每条指令携带 epoch[31:0]、primitive_id[31:0]、
engine/mode、k、公开 i/j/nonce、src/dst 的 page/allocation_id、输入/输出长度和安全域。
请求 valid 到 ready 期间所有字段保持，fire 后进入 WAIT；不持续拉高 prim_start
反复启动同一操作。primitive_id 在同一 epoch 中不复用，达到上限禁止新发射。

完成响应必须匹配 epoch、primitive_id、engine、目标 allocation_id 和预期字节/系数
计数。相同 ID 的重复完成、当前 epoch 的错误 ID 是完整性错误；已撤销 epoch 的迟到
响应仅丢弃并计入排空，不写页、不推进 PC。WAIT 允许后续周期返回；不接受请求火沿
的组合 done。操作数页须 VALID，结果页须已预留 FILLING；响应成功且写回确认后才
转为 VALID。页别名只允许 POLY 已定义的 in-place NTT，MAC 累加使用不同工作页。

PC/循环/字节计数附奇偶位，每次使用先检查；i/j 使用 3 bit（含 k 终止值），nonce
使用 8 bit，ct 游标 11 bit（含 1568），SS 游标 6 bit（含 32）。不因秘密失配改变计数。
禁止用“任何引擎 done 的 OR”代替匹配响应。所有 timeout 都进入失败清除，不能推进 PC。

<!-- LLD_FSM_META
id: LLD.FSM.PQC.KEMSEQ.DISPATCH
module_ref: LLD.MOD.PQC.KEMSEQ
encoding: onehot
reset_state: CLEAR
states: [CLEAR, IDLE, CHECK, ISSUE, WAIT, ADVANCE, CUSTODY, RESULT, FAIL, LOCKED]
illegal_state_handling: fatal
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.002
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x7'
transitions:
- {source: CLEAR, destination: IDLE, condition: local_wipe_and_all_participants_drained_and_no_clear_and_no_lock}
- {source: CLEAR, destination: LOCKED, condition: clear_timeout_or_lock_after_clear}
- {source: IDLE, destination: CHECK, condition: command_fire_and_no_cancel}
- {source: CHECK, destination: ISSUE, condition: public_checks_ok_and_grant_if_required_valid}
- {source: CHECK, destination: FAIL, condition: public_format_or_authorization_error}
- {source: ISSUE, destination: WAIT, condition: primitive_request_fire}
- {source: ISSUE, destination: FAIL, condition: unexpected_current_epoch_response_or_request_timeout}
- {source: WAIT, destination: ADVANCE, condition: matched_success_and_destination_writeback_complete}
- {source: WAIT, destination: FAIL, condition: matched_error_or_current_epoch_identity_error_or_timeout}
- {source: ADVANCE, destination: ISSUE, condition: next_instruction_exists}
- {source: ADVANCE, destination: CUSTODY, condition: keygen_program_finished}
- {source: ADVANCE, destination: RESULT, condition: encaps_or_decaps_program_finished}
- {source: ADVANCE, destination: FAIL, condition: duplicate_current_epoch_response}
- {source: CUSTODY, destination: RESULT, condition: matching_custody_ack_and_no_revoke}
- {source: CUSTODY, destination: FAIL, condition: custody_failure_or_timeout}
- {source: RESULT, destination: CLEAR, condition: fe_result_fire_then_retirement_clear}
- {source: FAIL, destination: CLEAR, condition: error_latched_by_fe_and_clear_started}
- {source: IDLE, destination: CLEAR, condition: clear_revoke_or_fatal_priority}
- {source: CHECK, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: ISSUE, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: WAIT, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: ADVANCE, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: CUSTODY, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: RESULT, destination: CLEAR, condition: cancel_revoke_or_fatal_priority}
- {source: FAIL, destination: CLEAR, condition: clear_revoke_or_fatal_priority}
END_LLD_FSM_META -->

状态未列条件自环，取消/故障高于所有普通握手，非法/多热状态立即 fault 并转 CLEAR，
设置 lock_after_clear。RESULT 仅提供操作结果句柄/长度，数据在 staging 保持至 FE
提交/退休；KEMSEQ 本地清除不能提前擦掉 FE 尚未消费的输出页。FE 承担全局提交后
清除，RESULT→CLEAR 先清本地临时寄存器，页清除由全局退休授权控制。

CLEAR 屏蔽新请求/结果，向涉及引擎发 cancel 并等待真实 drain/clear ack；未决 DMA
由 FE/FAULT 汇聚。本地清除 PC/token/游标/比较/候选密钥，clear_done 只代表本地及
所发原语退休，不能替代 FAULT 全局完成。LOCKED 持续清除并吸收迟到响应，不能新接命令。
低有效异步复位，CORE 同步释放；复位先 CLEAR，数据寄存器归零，身份有效位无效。

## 三种操作的程序顺序

下表每个序列项由 ISSUE/WAIT/ADVANCE 包裹；内含循环的项按公开索引逐原语展开。
微程序的语义依赖固定，具体引擎逐拍周期由对应分册提供，尚未形成整条路径周期签核。

| 入口 | 必须执行的依赖链 |
|---|---|
| KeyGen | 取得 d,z → G(d‖k) → CBD s/e → NTT s/e → 矩阵逐项生成与 MAC → 加 e → 编码 ek/dk → H(ek) → WORKKEY 组装与托管 |
| Encaps | 检查 ek → 取得 m → H(ek) → G(m‖H(ek)) → 下述 Encrypt → 获准密文及 SS staging |
| Decaps | 检查 dk/ct → 解码 u/v → NTT u → ŝ·û、逆变换、v 减结果 → Compress1/编码 m' → G(m'‖h) → Encrypt 得 c' → 全长比较 → J(z‖c) → 32 B select |

KeyGen 的 s nonce 为 0..k-1，e 为 k..2k-1；两者 eta1。矩阵按输出行 i 和
内积 j 重放，每次只保留一项；A[i,j] 的 XOF 后缀为 (j,i)。ŝ 保留 k 页，ê/t̂
复用另一组 k 页。每行 MAC 使用独立 accumulator，再加 ê[i] 并写回该行；最后
序列化 ŝ 至 WORKKEY，ek 至 staging，同时把 ek/h/z 送 WORKKEY，不能普通 DMA 导出 dk。

Encrypt 共用于 Encaps 与 Decaps，区别只有最终密文的发布权限：y 的 nonce 为
0..k-1、eta1；e1 为 k..2k-1、eta2；e2 为 2k、eta2。先保留 ŷ，按输出 i 计算
A 的第 i 列与 ŷ 的内积，因此矩阵项 A[j,i] 的 XOF 后缀为 (i,j)，不可沿用 KeyGen
的后缀次序。逆变换后加 e1[i]，逐多项式压缩编码 u；再计算 t̂·ŷ、逆变换，加 e2
和消息编码得到 v 并压缩。各次 PRF 上下文重建，不能让 nonce 延续前一命令。

Decaps 解码输入 ct 至受控页；u 为公开输入，但 ŝ·û 和后续结果保持秘密域。
重加密 c' 即使类型是 ciphertext，在比较/选择前仍标为 secret，禁止对外 staging
或 DMA。比较后先执行 J，再执行 select，符合已有 HLD 顺序；有效与失配路径完全一致。
J 输入始终使用原始完整 c，不能误用 c'。短/长 ct 是公开输入错误，不进入此路径。

存储预算沿用 HLD 的 24 页上限：两组向量最多 8 页、4 页矩阵/累加/临时、4 页
公开输入、4 页输出/重加密区、2 页流缓存、2 页转换临时。具体页号和逐拍 bank 访问
尚需结合 SAMPLER/CODEC 冻结；本表只确立角色与复用顺序，不宣称容量表证明无别名。

## 比较和共享秘密选择的数据通路

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KEMSEQ.COMPARE_SELECT
module_ref: LLD.MOD.PQC.KEMSEQ
input_width: 8
output_width: 8
operators: [full_length_xor_or_reduce, masked_equality_reduce, full_length_secret_select]
representation: public_ciphertext_and_secret_two_share_candidates_at_level2
req_ref:
- LRS.FUNC.PQC.KEM_DECAPS.001
- LRS.FUNC.PQC.KEM_DECAPS.002
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x7'
END_LLD_DATAPATH_META -->

比较按位置 0..ct_len-1 配对，两个读响应均带 epoch/index；分别有一个保持槽，
COMPARE/SELECT 是本模块内部执行端点，也经 ISSUE/WAIT/ADVANCE 退休；与外部引擎
互斥，不发外部 prim_start。内部结果沿寄存，下一拍作为绑定 token 的响应返回。
身份错误高于匹配响应；取消/故障又高于身份错误，不允许相同沿发放结果后才撤销。
以下数据配对规则适用于该内部端点：
收齐同一位置才计算 diff_next = diff | (c_byte XOR cprime_byte)。stall 保持数据、
地址和计数，收到单边响应不推进。最后字节必须计入 diff_next 后才能得到选择标记，
不能误用旧 diff。失配不提前终止，不改变地址/请求数/输出长度/完成状态或中断。

Level 0/1 选择为 mask = -(diff==0)，SS[j]=(K'[j]&mask)|(Kbar[j]&~mask)，j=0..31；
每字节写入已授权 secret staging，写回握手才增加 j，最后写确认后结果就绪。
在 Level 2 中 diff/equality/mask 也必须保持两 share，OR/归约/选择使用 HPC3+，
不能使用未掩码的 diff==0 或把 verify_mask 输出到 TOP。具体 gadget 列表、配额及
固定延迟尚需 CODEC 合同闭环，普通布尔模型不能证明这些操作的掩码组合安全。

共享秘密只在选择完成、全部写回与授权重检之后，经 HLD 规定的安全输出路径发布；
K'/Kbar/失配标记不接 CSR、调试口、普通 DMA 或完成状态。正常失配仍返回 SUCCESS。
BUS/ECC/RNG/授权/原语错误属于系统失败，抑制所有输出并清除，与密文失配严格分离。

## RTL TODO 与证据边界

当前旧 byte 接口的局部修复保证 `ss_addr/ss_wdata/ss_we` 同拍，zeroize
组合撤销写使能、完成和原语请求。该旧接口没有写背压，暂以每个有效沿写入为合同；
后续端点必须替换为前述带身份与背压接口。`ut_pqc_kem_select` 使用按地址变化的
秘密候选检查全部 32 个写地址和值，逐位置注入三个密文长度的失配，并核对完成
时延不变及撤销优先；不覆盖完整解封装算法或 Level 2 掩码安全性。
旧接口另外锁存输入密文长度，并校验 rank 对应的 768/1088/1568 字节，非法 op、
rank 或长度产生公开错误。启动清计数器，避免前一命令影响下一命令时延。
每个原语只在 !prim_busy 且无 pending 时发出一拍 start；只有 pending 的 done
才能推进。该局部规则防止忙时发射与重复发射，仍不替代完整 token 响应接口。

P0 `rtl/pqc_kem_seq.sv`：实现本册 DISPATCH/COMPARE_SELECT，替换当前单次 prim_done
结束操作、op_error 常零、外部长度作循环界、未握手比较及 verify_mask 旁带。
同时对齐 TOP/引擎 token 接口，Kbar 真正计算不可由零值占位。已有 UT 只覆盖骨架。
控制模型检查程序依赖、公开循环界、请求身份及全长比较，不是 FIPS KAT 或 RTL 验证。
仍待完成：精确页生命周期/非 NTT bank 轨迹、采样与转换 gadget、完整周期/PPA 收敛。
