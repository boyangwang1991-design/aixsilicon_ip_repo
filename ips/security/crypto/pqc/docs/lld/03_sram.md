# PQC SRAM 授权、bank 调度与清除微架构

### LLD.MOD.PQC.SRAM

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.SRAM
name: pqc_secure_sram_ctrl
parent_ref: HLD.MOD.PQC.SRAM
hld_ref:
- HLD.MOD.PQC.SRAM
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.CT.003
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_secure_sram_ctrl
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 物理组织与逻辑地址

逻辑容量 `LOCAL_SRAM_KIB ∈ {32,64,96}`，每页 256 个 32-bit word，1 KiB。
Level 0/1 为 8 bank，每 bank 1R1W；Level 2 为两套相同 bank，两个 share 使用
相同公开地址但独立数据、ECC、读暂存及写暂存。禁止运行时选 share 经一个数据口读回。
每 word 的 SECDED 编码为 39 bit；满容量 data+ECC 共 `LOCAL_SRAM_KIB*256*39`
bit/域。页 tag、word 初始化位和响应 token 另计，不隐藏在逻辑容量内。

逻辑 word 索引 w：page=w>>8，i=w&255；bank 为
`{i2 XOR i5, i1 XOR i4 XOR i7, i0 XOR i3 XOR i6}`，物理行
`page*32+(i>>3)`。PACKED、COEFF_STD 和 NTT_STD 使用同一映射；DMA 也经过
该映射，不能以线性地址直接索引不同布局的宏。bank 映射逐页是双射，所有 8 种
butterfly stride 的两个端点均分 bank；该性质不自动保证多 lane 同拍无冲突。

## 页生命周期与权限

页描述符保存 state、secret、representation、algorithm、pset、owner[7:0]、
domain[7:0]、command_epoch[31:0]、allocation_id[31:0]、logical_words[8:0]、
tail_keep[3:0]、ecc_status。每 word 有 initialized 位，两个 share 原子置位。
allocation_id 在当前 command 内递增，耗尽时停止，不能在旧响应可能存在时复用。
allocation 请求仅来自 sequencer 的静态页计划，CSR 和 DMA 均不能改 tag。

<!-- LLD_FSM_META
id: LLD.FSM.PQC.SRAM.PAGE
module_ref: LLD.MOD.PQC.SRAM
encoding: binary
reset_state: FREE
states: [FREE, FILLING, VALID, RETIRING]
illegal_state_handling: fatal
req_ref:
- LRS.SEC.PQC.CT.003
- LRS.SEC.PQC.ZEROIZE.001
- LRS.FUNC.PQC.KEM_DATAFLOW.001
applicability:
  expr: 'true'
transitions:
- {source: FREE, destination: FILLING, condition: authorized_allocate_and_clean_page}
- {source: FILLING, destination: VALID, condition: publish_and_all_required_words_initialized_and_no_pending_write}
- {source: FILLING, destination: RETIRING, condition: cancel_or_revoke_or_clear_priority}
- {source: VALID, destination: RETIRING, condition: last_consumer_retired_or_revoke_or_clear_priority}
- {source: RETIRING, destination: FREE, condition: all_page_words_and_response_slots_cleared}
END_LLD_FSM_META -->

FREE 表示不可读；cold reset 后另有全局 scrub_busy，完成全阵列物理清除前不可分配。
FILLING 只允许拥有相同 allocation_id 的生产者顺序写入；未初始化 word 不返回
上个对象残留。普通消费者仅能读 VALID；producer 原地更新仅可在独占原语 token
下读已初始化 word，仍要求身份/表示一致。发布只在最后写确认后生效。

dispatch 时检查整组页，**每次接受访问时仍重新检查**页状态及完整 tag，以抵抗
dispatch 后撤销。请求字段包含地址、read/write、完整期望 tag、request_id、
primitive_id；来源端口决定权限，不能由 payload 自报来源。普通 DMA/PIO/debug
拒绝 secret 页、任一 share、候选签名 staging；成功签名经独立 commit 授权后
才可把最终公开编码页转为普通输出。WORKKEY 不在此地址空间。

每次访问失败返回绑定原请求的 error 响应和零数据，不修改 RAM、tag 或 initialized；
未接受的请求不能产生错误脉冲。secret/表示等标签是公开调度元数据，访问与仲裁
不检查系数值。撤销/clear 在当拍屏蔽响应 valid，取消旧 epoch 响应，禁止事后恢复。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.SRAM.TAG_ECC
module_ref: LLD.MOD.PQC.SRAM
input_width: 32
output_width: 32
operators:
- full_tag_authorization
- bijective_bank_address
- secded_39_32_per_share
- response_identity_hold
representation: public_or_two_separated_shares
req_ref:
- LRS.SEC.PQC.CT.003
- LRS.SEC.PQC.INTEGRITY.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 周期、响应容量与 bank 预留

计算接口承接 POLY 的向量化 batch：每拍最多 `NTT_LANES` 个已排定 word 读请求
和相同数量写请求，等效于架构的两个计算访问组；DMA 为一组非预留请求。
原有标量 c0/c1 端口不足以实现 4 lane 预算，RTL 必须扩展内部请求组，不能只改参数。
每条 read 在 E0 检查授权且预留响应槽，E1 取得同步 RAM 码字，E2 完成 SECDED 并
注册双 share 结果。无背压且 slot 已预留时固定两拍；error 也在 E2 返回。
write 在接受沿原子写两个域的 ECC 码字并置 initialized；下一沿给写确认。

response 的 data/error/token 在 valid && !ready 时保持。每域每 bank 最多两个
在途读加一个返回寄存器；请求接受前计入两拍内将到达的响应，绝不只看当前输出
valid。计算 batch 的响应槽位由 POLY 六 slot 预先预留；非预留端口的 skid/credit
独立计数，不能覆盖已经保留给计算的槽位。响应拥堵时暂停相应新请求，已接受响应
仍有存放位置。清除不依赖下游 ready，直接失效并擦除本地返回寄存器。

NTT 在公开调度阶段预留发射+0/+1 读、+10/+11 写端口，优先于所有非预留访问。
非预留请求只竞争剩余 bank 端口，使用成熟 RR CBB；grant_ack 只在真实接受时推进，
不是 request 持续电平。与已预留地址发生 read/write 冲突时，非预留请求等待。
同地址读写不依赖宏的 read-during-write 模式：控制器禁止同拍受理，先写者完成后
再读。不同地址同 bank 的 1R1W 可并行。双 share 的仲裁 grant 和有效位必须一致。
RR 只对有空闲端口的公开请求保证公平，秘密运算期间 DMA 不获得预留端口。

## ECC、清除与 MBIST

标量 DMA 端口增加 `d_wstrb[3:0]`。非零部分写在同一个仲裁事务内读取旧字、
完成 SECDED 校正、按 byte enable 合并并重新编码；未初始化字的未写字节为零。
全零 strobe 是无存储副作用的完成，不能发布 page/word 有效位。全字覆盖不消费旧码字。
已初始化字的部分写若发现双错，不更新任何字节或有效位，报告 ecc_ued；单错先校正
再合并并报告 ecc_ded。不得先覆盖错误码字再声称合并成功。

标量过渡实现也必须拒绝 DMA 对 secret 页的读和写。同拍 tag 更新与同页访问冲突时
不接受访问；tag 撤销/改为 secret 同拍要撤销旧 DMA 响应，数据返回零。该隔离不替代
上文完整 owner/domain/epoch/allocation 授权，后者仍需实现。

单 bit 错误在响应前纠正，报告 recoverable；后台 scrub 携带 allocation_id，只有
标签仍匹配且没有更新的写时才写回，避免旧纠正值覆盖新数据。双 bit 错误不发布
任何域的数据，置 fatal 并触发全局安全收尾，不能把 UE 当可纠正告警。

全局 clear 立即拒绝新请求、作废所有页和未退休响应；独立计数器按物理行递增，
每拍写同一行的 8 个 bank、Level 2 两域并行，覆盖全部 data/ECC/initialized。
清 tag、scrub 暂存和返回数据与清除序列并行，最后写入确认后再等两拍流水清空，
内部界限为 `32*LOCAL_SRAM_KIB+2` 拍，从首个擦除沿计数。32/64/96 KiB 分别
1026/2050/3074 拍；这些是本结构的设计界限，尚无 RTL/宏证据。
FAULT 还须独立等待 DMA 排空，外部 AXI 永久背压不在该内部界限内，超时不能报成功。
局部 RETIRING 页按同样方法擦除 32 行，清除期间不能重新分配。

MBIST 只在测试生命周期、无活动授权且全局擦除确认后进入；期间禁止正常读写。
退出后重新全容量擦除并执行自检，不能将测试图样作为 VALID 页。秘密 FIFO/响应
不复用缺少内容擦除的通用 sync_fifo；RR CBB 用 FuseSoC depend，ECC/清除逻辑
保留 IP 所有权，依赖成熟度依据 docs/reuse_plan.md。

RTL TODO：`rtl/pqc_secure_sram_ctrl.sv` 实现完整请求标签、双域、向量 bank 请求、
响应 credit 和独立物理擦除；MAC/采样/转换的实际端口轨迹尚须与各自 LLD 联合核算。
设计模型只验证地址双射、访问资格和撤销顺序，不替代 RTL ECC、宏时序或安全证明。


## 现有 scalar 响应口的撤销边界

当前 SRAM 控制器在 reset、zeroize 请求同拍和物理 sweep 期间屏蔽三个 ready，
读数据只有所属端口 ready 有效时才展示；其他端口及空闲周期输出零。tag_check_ok
在同一边界立即失效，sweep 期间不接受 tag 发布，防止擦除过程中重新授权。
这只修正现有 scalar 端口，完整双 share/tag/epoch 协议仍按本册目标继续实现。

## 当前候选综合入口约束

FuseSoC synth/lint选择rtl/synthesis/pqc_ecc_sram.sv纯存储空壳，仿真/UT选择
rtl/pqc_ecc_sram.sv行为视图。综合脚本检查源清单并要求保留working SRAM与
WORKKEY两个存储实例。行为级数组不得进入逻辑映射；ECC/授权/清零控制仍综合。
当前word_valid是每word一bit的必要有效性元数据，32/64/96KiB对应8192/16384/24576bit；
页失效采用按物理DEPTH生成的固定页寄存器组（小型SIM_WORDS末页允许不足256bit），避免256个动态写位置的组合展开。它仍计入控制逻辑面积。
无真实宏库时只允许标为排除SRAM宏面积与宏延迟的逻辑表征，不得宣称完整PPA达标。
