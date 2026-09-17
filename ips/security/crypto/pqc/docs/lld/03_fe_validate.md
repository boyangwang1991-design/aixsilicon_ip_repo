# PQC 描述符语义校验子模块

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.FE.VALIDATE
name: pqc_desc_validate
parent_ref: LLD.MOD.PQC.FE
hld_ref: [HLD.MOD.PQC.FE]
req_ref: [LRS.FUNC.PQC.CMD.002, LRS.FUNC.PQC.CMD.003, LRS.FUNC.PQC.DSA_MESSAGE.001]
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_desc_validate
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
END_LLD_MODULE_META -->

## 边界与存储归属

FE 保留唯一 128 B shadow、CRC 和命令生命周期；本模块只作组合解码与公开字段校验，
不复制 shadow，不访问私钥，不发 DMA。FE 在 VALIDATE 沿接受结果，之后 shadow 不再
改变，直到命令退休或清除。输出 `pqc_command_t` 是已解码的字段视图；仅 valid=1
时允许用于后续数据访问。错误时 command 全零，避免下游误用未校验地址。

CRC 由 FE 的真实抓取路径计算，作为 crc_ok 输入；本模块仍检查 ABI、保留字和 flags。
权限/材料 acquire 在公开字段全部通过后由 FE/WORKKEY 完成，不能把本模块 valid
解释为私钥 grant。valid 只表示公开结构合法，不表示密码结果或算法已实现。

## ABI 与算法缓冲区映射

ABI 固定 0x10，little-endian，保留原始合同 §20.1 的 128 B 布局：
header、command_id、完整 key_handle 分别位于 0x00/04/08；0x0c 为保留字；
src0 地址/长度为 0x10/18，src1 为 0x20/28，context 地址/长度为 0x30/38，
entropy_policy 为 0x3c，dst0 地址/容量为 0x40/48，dst1 为 0x50/58，completion
地址为 0x60，timeout_hint 为 0x68，0x6c..7b 保留，CRC 为 0x7c..7f。
header 中 opcode/pset/flags/ABI 宽度为 8/4/12/8。当前 flags 必须为零，不能忽略未知位。

以下为现有双源 ABI 的明确分配，不引入新的描述符版本：

| 操作 | SRC0 | SRC1 | DST0 | DST1 |
|---|---|---|---|---|
| KEM KeyGen | 无 | 无 | ek | 4 B handle |
| KEM Encaps | ek | 无 | ciphertext | 32 B shared secret，受安全输出授权 |
| KEM Decaps | ciphertext | 无 | 32 B shared secret，受安全输出授权 | 无 |
| DSA KeyGen | 无 | 无 | pk | 4 B handle |
| DSA Sign | message，可空 | 无 | signature | 无 |
| DSA Verify | message，可空 | pk 紧接 signature | 无，仅 completion.valid | 无 |

Verify 的 SRC1 把两个固定大小的公开对象连续排列，pk 在前、signature 在后；分别
送解码端点，不能当作一个密码编码对象。三参数集长度为 3732/5261/7219 B。
这解决两组源地址无法分别承载 pk/message/signature 三个对象的缺口；使用用户已委托
的推荐设计决策。后续驱动与系统测试必须按此映射，不得各自解释 SRC1。

KEM ek 为 800/1184/1568 B，ciphertext 为 768/1088/1568 B；DSA pk 为
1312/1952/2592 B，signature 为 2420/3309/4627 B。固定格式输入必须精确匹配长度，
输出容量不得小于所需长度。KeyGen 的私钥不在这些 buffer 中，只走专用托管接口。
无输入的字段长度必须为零；DSA message 保留完整 64-bit 长度，零长度合法。
只有 Sign/Verify 使用 context，长度 0..255；其他操作 context_len 必须零。

entropy_policy 只允许 0/1/2；Sign 分别表示 deterministic/hedged/production（默认
采用 hedged），KeyGen/Encaps 仅允许 production=2；KAT seed 的可信测试导入另行实现，
不能借 SRC1 导入秘密种子。Decaps/Verify 不因此改变标准算法，但仍检查编码范围。
ZEROIZE/SELF_TEST 的命令退休路径尚未接通前，不能借本模块伪装成已实现的算法命令。

## 地址与重叠

地址字段先按完整 64 bit 检查，禁止截到 AXI 位宽后再校验。每个实际使用的源、context、
输出容量和 32 B completion 范围均用 65-bit 加法计算最后字节，拒绝溢出及越出
DMA_WINDOW_BASE..DMA_WINDOW_LIMIT 的范围。未使用且长度为零的地址不产生访问。
本模块默认窗口为 40-bit 全空间；TOP 应显式传递与其 DMA 实例相同的受信窗口。

非空 payload 起始地址按 DMA_DATA_WIDTH/8 对齐；completion 地址额外按 32 B 对齐，
descriptor 按 128 B 对齐。输出按声明容量检查整个范围，不能把溢出的容量截断。
读缓冲区之间可重叠；任何非空输出和 completion 不得覆盖输入、context、descriptor，
输出之间及与 completion 也不得重叠。使用闭区间比较，首尾相邻但不重叠的范围合法。

错误优先序：ABI/CRC/保留/flags、opcode/pset/capability、长度/context/entropy、
容量、对齐、地址范围/重叠。对应公开错误为 BAD_ABI、BAD_OPCODE/BAD_PARAMSET、
BAD_LENGTH、BAD_CAPACITY、BAD_ALIGN、PERMISSION；不泄漏秘密相关信息。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.FE.VALIDATE
module_ref: LLD.MOD.PQC.FE.VALIDATE
input_width: 1024
output_width: 1
operators: [little_endian_decode, exact_public_length_lookup, capacity_compare, extended_range_add, write_read_overlap_check]
representation: public_descriptor_fields
req_ref: [LRS.FUNC.PQC.CMD.002, LRS.FUNC.PQC.CMD.003, LRS.FUNC.PQC.DSA_MESSAGE.001]
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 周期、复位与资源

纯组合模块，无 FSM、无局部状态，也无独立清除应答。FE 的 shadow 清除与状态门控
负责停止使用视图。组合比较只处理公开数据，允许一个 VALIDATE 周期；若时序需要
流水，可在 FE 内保留 validated 快照并加状态，不把后续寄存器结果误用为当前命令。
这里没有物理时序签核；当前优先保证边界正确。

<!-- RTL_MAP_META
id: RTL.PQC.FE.VALIDATE
rtl_file: rtl/pqc_desc_validate.sv
rtl_module: pqc_desc_validate
implements: [LLD.MOD.PQC.FE.VALIDATE, LLD.DP.PQC.FE.VALIDATE]
END_RTL_MAP_META -->
