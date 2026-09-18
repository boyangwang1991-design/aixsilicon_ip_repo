# 工作态 Key RAM 微架构

本卷承接已冻结 HLD 的单份逻辑工作密钥和专用 Key Manager 接口。当前 RTL 只有
导入/ECC/擦除子集；以下是待实现合同，G2 保持开放。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.WORKKEY
name: pqc_work_key_ram
parent_ref: HLD.MOD.PQC.WORKKEY
hld_ref:
- HLD.MOD.PQC.WORKKEY
req_ref:
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
- LRS.INTF.PQC.KEY_MANAGER.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_work_key_ram
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 存储与身份

KEY_BYTES 固定工作容量为 8192；2048 个 32-bit word，每 word 独立 39-bit SECDED。
SCA_LEVEL=2 生成两个分离的 2048×39 数组及两份读/纠错寄存器；其他等级一份。
综合期裁剪，不能通过运行时位旁路第二 share。数组不使用异步复位循环，复位仅
清控制/流水有效位并进入逐地址擦除。两个 share 同地址并行擦除，不能因物理翻倍
擅自把逻辑 byte count 翻倍。

锁存身份为 handle[31:0]、owner[7:0]、domain[7:0]、algo[3:0]、pset[3:0]、
usage[7:0]、logical_bytes[15:0]、transaction[31:0]、command_epoch[31:0]。
epoch 在 TOP 分配，退休后不得在同一复位周期内回绕；耗尽时拒绝新命令并要求安全复位。
内部 origin_generated 只能由已接受 KeyGen 命令产生，外部导入头不能设置该标记。

私钥长度按 pset 锁定为 1632/2400/3168/2560/4032/4896 B。全部为整 word，
不接受私钥尾部任意 strobe 或多余 word；用途非零且与算法操作兼容。
材料存在不等于算法编码有效；ECC 扫描只完成存储检查，算法入口仍检查规范编码和 H(ek)。

<!-- LLD_BUFFER_META
id: LLD.BUF.PQC.WORKKEY.MATERIAL
module_ref: LLD.MOD.PQC.WORKKEY
type: sram
depth: 2048
width: 39
implementation_intent: sram
full_behavior: error
empty_behavior: stall
req_ref:
- LRS.SEC.PQC.SLOT.006
applicability:
  expr: 'true'
END_LLD_BUFFER_META -->

上述单域模板在 Level 2 实例化两次；META 的 width/depth 不把第二域隐藏成免费容量。
有效长度和整块身份足以约束顺序导入，不增加可由普通软件改写的逐 word 有效 bitmap。

## 专用事务接口

<!-- LLD_INTERFACE_META
id: LLD.IF.PQC.WORKKEY.KM
owner_module: LLD.MOD.PQC.WORKKEY
hld_ref:
- HLD.IF.EXT.PQC.KEY_MANAGER
protocol: atomic_dual_share_stream
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
applicability:
  expr: 'true'
END_LLD_INTERFACE_META -->

| 接口组 | 负载 | 握手与保持 |
|---|---|---|
| import_header | 上述完整身份，长度、用途 | valid/ready；只在 EMPTY 且 TOP idle/授权时接受 |
| import_word | data_s0[31:0]、data_s1[31:0]、last | 两域共用 valid/ready，stall 时全部稳定 |
| internal_read | word[10:0]、完整匹配身份、请求 token | req_valid/ready；只向授权 sequencer/codec 返回 |
| internal_response | 两域 data[31:0]、token、error | rsp_valid/ready；两域原子退休 |
| generated_word | KeyGen 专用身份、两域数据、last | 只由已派发 KeyGen 写入，不与 import 混用 |
| custody_header/word | 新生成标记、逻辑长度、身份/数据 | 专用出站；背压保持，普通 AXI 无此入口 |
| custody_ack | transaction、epoch、handle、owner/domain、bytes、success | 必须全部匹配当前等待对象；不接受迟到 ACK |
| revoke | handle、owner/domain；或全局撤销 | 匹配即优先撤销；不等候普通 read/ACK |

Level 2 导入和托管输出都用新的 32-bit 随机量对两域各 XOR 刷新后锁存；每个 word
只消费一次 token，背压不重复刷新。可将一个 64-bit token 的两半顺序用于两个 word，
但消费游标和 epoch 必须保留，不能在 cancel 后复用剩余半字。刷新不重构私钥。
普通命令读不提供单独的 share select，由内部固定的两个数据域分别连接消费者。

## 状态与优先级

<!-- LLD_FSM_META
id: LLD.FSM.PQC.WORKKEY.MAIN
module_ref: LLD.MOD.PQC.WORKKEY
encoding: onehot
reset_state: WIPE
states:
- WIPE
- EMPTY
- IMPORT
- GENERATE
- SCAN
- READY
- CUSTODY_HEADER
- CUSTODY_WORD
- CUSTODY_ACK
illegal_state_handling: fatal
req_ref:
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
applicability:
  expr: 'true'
transitions:
- source: WIPE
  destination: EMPTY
  condition: last_zero_write_and_pipeline_clear_done && !clear_request
- source: EMPTY
  destination: IMPORT
  condition: authorized_import_header_handshake
- source: EMPTY
  destination: GENERATE
  condition: authorized_internal_generated_header_handshake
- source: IMPORT
  destination: SCAN
  condition: expected_final_word_handshake
- source: GENERATE
  destination: SCAN
  condition: expected_final_word_handshake
- source: SCAN
  destination: READY
  condition: all_ECC_responses_ok && !origin_generated
- source: SCAN
  destination: CUSTODY_HEADER
  condition: all_ECC_responses_ok && origin_generated
- source: CUSTODY_HEADER
  destination: CUSTODY_WORD
  condition: out_header_handshake
- source: CUSTODY_WORD
  destination: CUSTODY_ACK
  condition: expected_final_out_word_handshake
- source: CUSTODY_ACK
  destination: READY
  condition: identity_matched_ack_success; pulse custody_success
- source: CUSTODY_ACK
  destination: WIPE
  condition: identity_matched_ack_failure || timeout
- source: EMPTY
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: IMPORT
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: GENERATE
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: SCAN
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: READY
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: CUSTODY_HEADER
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: CUSTODY_WORD
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
- source: CUSTODY_ACK
  destination: WIPE
  condition: 'priority: clear/revoke/fatal/retire; or state-specific protocol/ECC/timeout
    error'
END_LLD_FSM_META -->

每个时钟沿优先级：reset > zeroize/匹配 revoke/fatal > retire > 状态内握手。
上述撤销信号组合屏蔽所有材料 valid 和 grant；该沿清流水有效位/身份并进入 WIPE，
不能与同沿最后一个数据字或 ACK 一起产生 load_done/custody_success。

WIPE 每拍写一个地址，两个域同时写合法零 ECC codeword；最后地址写完后再经过
清除流水确认才进入 EMPTY。请求持续有效期间不接受新头，zeroize_done 表示本域
已擦除并维持安全，不代表外部 AXI/KM 已排空。对 KEY_BYTES=8192，内部完成上界
2048+2 周期（从清除被时钟采样起计），不重复从零启动正在进行的 sweep。

IMPORT/GENERATE 只在 word 握手时增加计数。last 必须且只能出现在期待的最后 word；
过早/缺失/超长/身份改变进入 WIPE，统一 load_error，不产生有效 key。输入断流由
TOP 的公开事务超时终止，不能把未写 word 当成零自动补齐。

最后 word 写入后进入 SCAN；扫描与计算读互斥，按长度发出同步读并等待最后一个
纠错结果返回。双域任一不可纠正错误进入 fatal/WIPE；可纠正错误更正后继续，
是否回写占用单独公开周期，不与下一次数据写争用。扫描完成后才产生 load_done。
导入材料进入 READY；新生成材料进入 CUSTODY_HEADER，不允许软件触发任意材料导出。

CUSTODY_WORD 通过同一 ECC 读流水取数据，再刷新并输出；一次只保留一个出站 word，
stall 不读下一个地址、不覆盖当前两域寄存器。最后 word 已接受后才进入 CUSTODY_ACK。
只接受本事务 ACK，成功后告知 FE 可以继续公钥/完成记录提交；失败/超时清除。
成功不自动授予导入材料的导出权限，command retire 仍擦除本地副本。

## 读流水

<!-- LLD_PIPELINE_META
id: LLD.PIPE.PQC.WORKKEY.READ
module_ref: LLD.MOD.PQC.WORKKEY
stages:
- AUTHORIZE_AND_RAM_READ
- ECC_AND_RESPONSE
stallable: true
flushable: true
req_ref:
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
applicability:
  expr: 'true'
END_LLD_PIPELINE_META -->

采用一个 outstanding 请求。E0 接受请求并锁存 token/身份/地址；E1 完成同步 RAM
读并锁存 raw；E2 ECC 解码后置响应 valid。正常情况下 E2 起可握手；响应退休前
不接受新读，避免带 token 的复杂乱序队列。该保守吞吐符合材料逐多项式解码路径，
后续若加速必须重做撤销与背压验证。

接受请求与响应发出前都检查 READY、身份匹配、用途包含、word*4<logical_bytes，
并检查 epoch 未撤销。非法请求返回固定格式错误/零数据，不访问 RAM。响应 pending
时身份或授权被撤销，立即屏蔽 valid/data 并清除寄存器，不能等待下游 ready 才擦除。
两域 ECC 从不先合并再校验；ECC syndrome/纠正位置不通过普通软件暴露。

<!-- RTL_MAP_META
id: RTL.PQC.WORKKEY
rtl_file: rtl/pqc_work_key_ram.sv
rtl_module: pqc_work_key_ram
implements:
- LLD.MOD.PQC.WORKKEY
- LLD.BUF.PQC.WORKKEY.MATERIAL
- LLD.FSM.PQC.WORKKEY.MAIN
- LLD.PIPE.PQC.WORKKEY.READ
generated: false
generator_ref: null
END_RTL_MAP_META -->

## 验证关注点与 PPA

关注 revoke 与最后字/ACK/响应同沿、两域 ECC 单独故障、导入后伪造 generated 标记、
跨 epoch 迟到响应、连续 backpressure、随机 half-word 不复用和全深度 wipe。
这些是设计关注点，具体 testcase/断言归 VPLAN。

面积以两个独立 RAM 域及 ECC/读寄存器计费，避免 2048 word 异步清零触发器阵列。
单 outstanding 降低授权/撤销状态复杂度，代价为材料读取带宽；不以材料 RAM 的
峰值带宽替代完整算法周期预算。没有新增私钥 AXI DMA 或普通 APB 读回路径。

## 当前候选物理存储边界

单域candidate把2048×39-bit材料数组实例化为pqc_ecc_sram，授权、SECDED、
导入扫描、读响应寄存与逐字擦除留在WORKKEY控制器。仿真使用异步读行为模型，
综合使用纯存储空壳；不得将整个WORKKEY模块黑盒化。物理宏读延迟变化需另行
修改控制器与验证，空壳不是实际SRAM时序或面积证据。
