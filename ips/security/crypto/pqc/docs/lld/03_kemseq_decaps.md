# KEM Decaps 调度与存储细化（draft）

本册是 KEMSEQ 内 Decaps 子程序的实现约束，补充既有命令/token/清除合同。
当前 `rtl/pqc_kem_decaps.sv` 已实现下述串行算术链、页分配和全长隐式拒绝，
三参数集正常/篡改密文已进入真实 UVM 验证；epoch、页授权、完整清除与 Level 2
仍未满足本册全部约束，G2 保持未冻结。
算法依据为 [FIPS 203 的 Algorithm 15、18、21](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf)。
以下页分配、串行 FSM 和端口保持规则为本项目工程设计；规范不提供这些硬件时序。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KEMSEQ.DECAPS
name: pqc_kem_decaps
parent_ref: LLD.MOD.PQC.KEMSEQ
hld_ref: [HLD.MOD.PQC.KEMSEQ]
req_ref: [LRS.FUNC.PQC.KEM_DECAPS.001, LRS.FUNC.PQC.KEM_DECAPS.002]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_kem_decaps
END_LLD_MODULE_META -->

## 入口与地址单位

接受时锁存 pset、由 pset 派生的长度，以及 WORKKEY 的 grant/epoch；运行中不读取
可变 CSR。公开长度错误在任何秘密运算前失败关闭。私钥属性与 H(ek) 检查必须绑定
同一授权；工作密钥导入成功不能代替这些校验。以下基址均以 32-bit word 为单位：

| WORKKEY 区段 | 基址 | 长度 word |
|---|---:|---:|
| s_hat 序列化值 | 0 | 96k |
| t_hat 序列化值 | 96k | 96k |
| rho | 192k | 8 |
| h | 192k+8 | 8 |
| z | 192k+16 | 8 |

多项式 packed 临时页每次只复制一项：s_hat[i] 从 `96*i` 开始复制96 word，
完成解码后才复用临时页；不能把整个向量写入一个256-word页后重复解码。
u[i] 从原密文 `i*(32*du)` byte 读取，单项解码、解压后再处理下一项。
v 从 `k*(32*du)` byte 读取，解码和解压是两个独立完成的原语。

## 非掩码串行程序的页生命周期

本表仅定义 SCA_LEVEL<2 的候选单命令布局，不作为 Level2 的双 share 存储方案。
每页256 word，页基址为 `page << 8`；所有页分配仍需通过 SRAM owner/domain/epoch
授权，不能为了使候选运算运行而把秘密页标为公开页。

| 页 | 解密阶段 | 重加密阶段 | 复用前提 |
|---|---|---|---|
| 0..3 | s_hat | t_hat | m' 已生成，s_hat 已退休/擦除 |
| 4..7 | u_hat | y_hat | 解密内积已完成，u 已退休 |
| 8 | 解密累加器 | 重加密累加器 | 每次内积前逐word清零 |
| 9 | v 与解密差值 | noise/message 临时 | m' 已锁存并擦除旧值 |
| 10 | 保留 | matrix 元素 | 逐项采样完整后才允许 MAC |
| 11 | packed 临时 | packed 临时 | 读消费者完成后才覆盖 |
| 12..13 | ek 序列化值 | ek 序列化值 | 从WORKKEY复制，用于H(ek)及t_hat解码 |
| 14..15 | 保留 | 保留 | 不读未初始化页 |
| 16..17 | 原密文 c | 原密文 c | 比较及 J 全部完成前只读 |
| 18..19 | 保留 | 保留 | 不能别名原密文 |
| 20..21 | 保留 | c' | secret，禁止输出 DMA |
| 22 | 结果 staging | 32B SS | 选择完成后才发布有效位 |
| 23 | completion | completion | SS 输出 B 响应后由 TOP 写入 |

最大密文1568B=392 word，占不足两页；布局不超过24页。矩阵、累加器和原密文
互不别名。这个容量计算不证明 Level2 两 share/转换/随机缓存足够。

## 原语依赖与握手

解密顺序为：逐项解码 s_hat → 解码并解压 u/v → 对每项 u 执行 NTT → 累加
全部 k 项乘积 → 一次 INTT → v 减累积值 → Compress1 → ByteEncode1。
消息为32B；从 packed word 提取 `[7:0]`、`[15:8]`、`[23:16]`、`[31:24]`，
不能把32-bit word的四个低位当作四个消息字节。

重加密消费已经锁存的 m'/r'，沿用 Encaps 的 Encrypt 原语顺序和页0..11布局；
不重新采集 entropy、不重复计算 G、不直接发布候选 K' 或 c'。同一时刻仅一个
操作控制共享原语。matrix 源页10、y_hat源页4+i、accumulator页8互不相同。
e1/e2 的采样模式及 nonce 采用既有 KEMSEQ 合同，不用空 WAIT 代替真实采样完成。

所有哈希请求分为配置、单拍 START、ABSORB、SQUEEZE、完成核对阶段。配置在
START 前已稳定；输入游标只在 `in_valid && in_ready` 时增加。SRAM预取时
`in_valid=0`，最后一个真实输入字节才断言 last。输出游标只在输出握手时增加，
末字节先写入保持槽再发布整条摘要。G 消费64B、产生64B；J 消费32B z和原始完整
c、产生32B。J 不能用零字节代替 c，原密文在 J 完成前不可被 matrix 写覆盖。

WORKKEY 读取使用 REQUEST→RESPONSE→WRITE：请求地址在接受之前保持，响应
data/error 先锁存，随后发 SRAM 写。不能在响应撤销后继续使用实时 `wk_read_data`。
H/rho/z 同样走该请求响应路径，不只支持 s_hat 的读取。错误优先于 valid。
SRAM请求保持到完成；读响应锁存后撤销请求，再发下一事务，不在一次 ready 上
同时消费两个地址。`mem_wdata` 必须由当前写事务的保持槽驱动。

## 比较、选择及退休

比较使用 word 游标时上界是 `ct_bytes/4`，最大392；9-bit游标可表示结束值。
使用 byte 游标时必须至少11 bit，不能把9-bit word游标与1568-byte上界比较。
每次收齐 c/c' 同地址返回后累积异或差，最后一项纳入结果后另拍生成选择掩码。
全部8 word结果均按掩码从 K'/Kbar 选择；相等和不相等路径有相同访存和控制轨迹。
既不能始终写 Kbar，也不能把 reject 标志放入 completion/IRQ/错误码。

算法 done 只代表内部32B结果写回；TOP 等 SS DMA 的 B 响应后写 completion，
再等 completion 的 B 响应后提交 FE。取消/revoke/zeroize 同拍压过全部请求和结果。
必须擦除消息、摘要、两个候选密钥、比较状态及临时页，清除完成前禁止接受新命令。
非法状态、超时或原语错误走统一失败清除；不能停在无错误、无进展的 BUSY。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KEMSEQ.DECAPS
module_ref: LLD.MOD.PQC.KEMSEQ.DECAPS
input_width: 32
output_width: 32
operators: [private_key_decode, ciphertext_decompress, decrypt_mac, recover_message, derive_candidates, reencrypt, full_length_compare, secret_select]
representation: normalized_kem_coefficients_and_serialized_bytes
req_ref: [LRS.FUNC.PQC.KEM_DECAPS.001, LRS.FUNC.PQC.KEM_DECAPS.002]
END_LLD_DATAPATH_META -->

<!-- RTL_MAP_META
id: RTL.PQC.KEM_DECAPS
rtl_file: rtl/pqc_kem_decaps.sv
rtl_module: pqc_kem_decaps
implements: [LLD.MOD.PQC.KEMSEQ.DECAPS, LLD.DP.PQC.KEMSEQ.DECAPS]
END_RTL_MAP_META -->

## 冻结前剩余事项

本册提供数据布局和握手修正目标；尚需token/页面授权、
Level2 掩码与随机消费实现、取消排空及周期表联合评审。未完成前维持 draft，
禁止将该文档抽取成功视为技术冻结或当前 RTL 算法通过。

## 串行候选实现状态交接

所有读写经MREAD/MWRITE保持请求，WORKKEY经WSTART单拍发出后在WWAIT锁存响应；
PSTART/PWAIT和CSTART/CWAIT一次只发一个原语。START的下一拍才消费done。
hash分HSTART、H_PK/H_CT预取、H_BYTE吸收、H_OUT输出及H_DONE交接。
DONE在TOP计算等待态直接采到一拍脉冲；FINISH擦除本地秘密后回IDLE。

| 程序段 | 状态序列/循环 | 退出条件 |
|---|---|---|
| 解码私钥 | D_S→D_S_READ→D_S_WRITE→D_S_UNPACK→D_S_NEXT | 每poly96 word、共k项完成 |
| 解码密文 | D_U→D_U_READ→D_U_WRITE→D_U_UNPACK→D_U_DECOMP→D_U_NEXT，之后D_V系列 | u/v均完成UNPACK与DECOMPRESS |
| 解密 | D_NTT→D_NTT_NEXT循环k项；D_ZERO→D_ZERO_NEXT清页8；D_MAC→D_MAC_NEXT循环k项；D_INV→D_SUB→D_COMP→D_PACK | 整内积仅一次INTT |
| 消息/ek | D_MSG→D_MSG_READ锁存8 word；D_PK→D_PK_READ→D_PK_WRITE复制96k+8 word | 原密文不被覆盖 |
| 私钥校验 | D_META→D_META_READ依次读取h/z；HASH_PK→D_HCHECK逐byte对比 | H(ek)全部32B一致，否则FAILED |
| 重加密 | COPY/UNPACK/CHECK读取ek系数，RHO读取rho；DERIVE→Encaps同构Encrypt调度 | c'全部word写入页20..21 |
| 拒绝与选择 | D_REJECT计算J；D_CMP→D_CMP_A→D_CMP_B→D_CMP_ACC固定长度；SS→SS_NEXT固定8word | 使用包含末word的完整diff进行无分支数据选择 |

WAIT状态未满足条件则自环。任意状态clear优先；非法状态进FAILED，输出error，
TOP接到error后走统一清除。本局部候选不宣称补齐全IP的token/Level2签核。
