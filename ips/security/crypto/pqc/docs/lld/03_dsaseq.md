# PQC DSASEQ 微架构（恢复中）

### LLD.MOD.PQC.DSASEQ

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.DSASEQ
name: pqc_dsa_seq
parent_ref: HLD.MOD.PQC.DSASEQ
hld_ref:
- HLD.MOD.PQC.DSASEQ
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.FUNC.PQC.DSA_SIGN.002
- LRS.FUNC.PQC.DSA_VERIFY.001
applicability:
  expr: 'ENABLE_ALGO_MASK & 0x38'
rtl_intent:
  separate_module: true
  suggested_name: pqc_dsa_seq
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

#### Responsibility

ML-DSA KeyGen/Sign/Verify 编排；拒绝采样循环与 `reject_accum` 累积；attempt 上限检测；
候选签名 staging 原子 commit。

#### Submodules

| Submodule | Responsibility | RTL Form |
|---|---|---|
| `LLD.MOD.PQC.DSASEQ.ATT` | attempt counter、reject_accum、上限检测 | submodule |

---


## 命令快照与原语完成归属

命令接受沿锁存 op/pset/flags、完整 epoch、私钥 grant、消息/context 和所有长度。
运行期间不读取实时 CSR 或依赖共享 engine 的全局 busy。每次 primitive 发射使用
`{command_epoch, attempt, primitive_seq, engine_id}` token；只有 valid/ready 接受后
才置 pending，只有匹配 token 的完成才清除。poly_done | kec_done 不能作为通用完成。

已退休 epoch 的迟到完成丢弃；当前 epoch 中未知/重复 token 不推进状态并进入内部
完整性错误。任一资源失败撤销该命令全部 pending，擦除临时页和结果。正常 DONE
只表示算法结果可交给 FE，成功 completion/IRQ 必须等 FE 完成写响应及必要托管 ACK。

## Sign 的数据依赖

先获得授权私钥并检查编码；计算 mu，确定本命令 rho'' 与起始 nonce。每次尝试按：
ExpandMask(y) → NTT/矩阵乘积得到 w → HighBits/挑战哈希 → SampleInBall/NTT(c) →
计算 cs1/cs2、z、r0 → 计算 ct0 → hint 与全部检查 → 统一边界判决。
全部对象保持 HLD 规定的表示；NTT(c) 是独立完成对象，不把挑战哈希完成当成 NTT 完成。

z=y+cs1；r0 取 w−cs2 的 LowBits；ct0 为 c*t0 的逆变换结果。hint 的两个输入
使用 −ct0 和 w−cs2+ct0 的规定分解，不能把 codec 任意两个实时端口当成该语义。
z、r0、ct0 的严格范数阈值及 hint 权重阈值分别来自 pset。固定阈值参与硬件比较，
不接受软件任意阈值。候选挑战、范数结果和拒绝累积在 Level 2 内均保持掩码。

### LLD.FSM.PQC.DSASEQ.ATTEMPT

<!-- LLD_FSM_META
id: LLD.FSM.PQC.DSASEQ.ATTEMPT
module_ref: LLD.MOD.PQC.DSASEQ
states:
- A_INIT
- A_EXPAND_Y
- A_NTT_W
- A_CHALLENGE
- A_CS1_CS2
- A_NORM_Z
- A_NORM_R0
- A_CT0
- A_NORM_CT0
- A_HINT
- A_PAD
- A_BOUNDARY
- A_ACCEPT
- A_REJECT
- A_EXHAUST
encoding: onehot
reset_state: A_INIT
illegal_state_handling: fatal
transition_notes: 所有正常检查均继续至 A_PAD/A_BOUNDARY；只在统一边界判定接受/重试，不能按首个 norm 失败提前退出
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.FUNC.PQC.DSA_SIGN.002
- LRS.SEC.PQC.CT.001
applicability:
  expr: ENABLE_ALGO_MASK & 0x38
transitions:
- source: A_INIT
  destination: A_EXPAND_Y
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_EXPAND_Y
  destination: A_NTT_W
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_NTT_W
  destination: A_CHALLENGE
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_CHALLENGE
  destination: A_CS1_CS2
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_CS1_CS2
  destination: A_NORM_Z
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_NORM_Z
  destination: A_NORM_R0
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_NORM_R0
  destination: A_CT0
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_CT0
  destination: A_NORM_CT0
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_NORM_CT0
  destination: A_HINT
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_HINT
  destination: A_PAD
  condition: all_state_operations_complete_with_matching_tokens; no early exit on
    reject bits
- source: A_PAD
  destination: A_BOUNDARY
  condition: fixed_attempt_budget_reached && all_mandatory_done
- source: A_BOUNDARY
  destination: A_ACCEPT
  condition: combined_masked_checks_accept; only aggregate decision declassified
- source: A_BOUNDARY
  destination: A_REJECT
  condition: combined_checks_reject && retry_and_nonce_available
- source: A_BOUNDARY
  destination: A_EXHAUST
  condition: combined_checks_reject && !retry_and_nonce_available
- source: A_REJECT
  destination: A_INIT
  condition: candidate_clear_done && pending_tokens_retired; advance nonce/attempt
- source: A_ACCEPT
  destination: A_INIT
  condition: FE command retired and new authorized sign command accepted
- source: A_EXHAUST
  destination: A_INIT
  condition: error retired and new authorized sign command accepted
END_LLD_FSM_META -->

每个状态中的原语仅发射一次，等待匹配完成后进入下一状态；检查失败不改变后续
正常状态序列。故障/撤销走独立清除，不伪装成正常拒绝重试。

结果 bank 为 `{z_done,z_ok,r0_done,r0_ok,ct0_done,ct0_ok,hint_done,hint_ok}`，
每项只能由对应 opcode+token 写入；A_INIT 清全部 done 和旧值。不能把多个检查
接到同一个 codec_norm_ok，再按当前 FSM 状态推断“应该是哪个结果”。对应 done
为零时 ok 不参加接受逻辑；全部 done 为真且其他运算/编码依赖就绪后才允许判决。

Level 2 的 ok/reject 使用双 share 表示，在 A_BOUNDARY 只释放一个统一接受/重试位，
不释放具体失败项。A_PAD 早完成时保持候选与掩码状态，直到配置对应的固定尝试
周期边界；达到边界而 mandatory done 不全，则统一内部错误并清除，不返回签名。

attempt 周期计数包含内部存储/随机仲裁、转换、采样填充；只有明确的外部服务
缺供周期可另行记录。该分项计数不替代总周期，不能将 DUT 自己拉低 ready 的
时间扣除。各 pset/security/lane 的数字预算与候选上限表尚待后续运算分册推导，
在表完整且与发射清单一致前 G2 不冻结；不以零或一个任意巨大常数填充验收。

A_REJECT 清除候选页、检查 done、pending token 与 ct0/hint 临时量，保留本命令
mu、rho'' 和私钥授权。nonce 按本参数集的向量长度增加，计算时多用一位检查溢出；
下一次 ExpandMask 所需 nonce 范围超出 16 bit 则 A_EXHAUST，不能回绕重放旧 y。
公开的 retry limit 与 nonce 上界两者取更严格限制。A_EXHAUST 返回统一错误，
不暴露最后的拒绝原因；A_ACCEPT 只开放完整 signature staging 的提交 grant。

## KeyGen 与 Verify 的退休

KeyGen 私钥写 WORKKEY 的 generated 通道，等待专用 custody 成功，再交给 FE 提交
公钥/handle；不能写普通 DMA 私钥缓冲。Verify 解码及 canonical 失败累计为 invalid，
按完整规定输入范围消费，比较完整 c~ 长度。c~ 参考值从输入签名取得，不允许常量零
或上一命令值；哈希长度/末字节/比对计数与当前 pset 一起锁存。

最终 valid 同时要求所有 mandatory 运算完成、编码规范、完整摘要一致及无故障；
使用双轨/重复最终比较结果，单个实时比较信号不能直接生成软件可见 valid。

## 当前实现差距

上述 token、ct0 检查和独立结果 bank 尚未在当前 RTL 全部实现；本卷定义修复目标。
现有局部 digest/staging UT 不能替代三参数集完整 Sign/Verify 与掩码验证。

## 现有 byte 原语接口的增量修正

当前 RTL 在接受 start 时锁存 op/pset，长度与后续状态选择只读快照。
每个原语在引擎空闲且无 pending 时只发一拍 start，收到 pending 对应的 done 后
才推进；等待期间不重复发射。该接口尚无 epoch/primitive token，完整身份协议、
独立 norm/ct0 检查与完整算法调度仍按上文落实，局部 UT 通过不代表 Sign 完成。


## 局部控制的配置拒绝与物理清除

当前 scalar 接口接受时只允许 op=KeyGen/Sign/Verify 和 ML-DSA 三种 pset；非法组合
设置 op_error 并结束，不发原语、不写 staging、不 commit。错误只表示公开配置错误。
verify_valid、retry_exhausted、op_error 在 reset/zeroize 同拍立即屏蔽。

两个 64 B 摘要 bank 在冷复位、zeroize、ct_clear 和命令 done 退休沿实际写零，
这些事件优先于同时到达的摘要写入。清指针不等于物理擦除；norm 锁存与比较累积
也由清除路径复位。该局部修复不能替代完整 masked Sign/Verify 的安全收口。
