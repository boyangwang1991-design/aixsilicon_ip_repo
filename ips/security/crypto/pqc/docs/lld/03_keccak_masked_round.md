# PQC 双 share Keccak 轮模块

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KECCAK.MASKED_ROUND
name: pqc_keccak_masked_round
parent_ref: LLD.MOD.PQC.KECCAK
hld_ref:
- HLD.MOD.PQC.KECCAK
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: SCA_LEVEL == 2
rtl_intent:
  separate_module: true
  suggested_name: pqc_keccak_masked_round
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 归属与端口

本模块只执行一轮 theta/rho/pi/chi/iota，属于 KECCAK 的执行数据通路。
KECCAK 上层拥有两个 context、24 轮计数、RC 查表、吸收和挤出；TOP.RANDOM
独占 600 B cache。本模块不重复建立 mask cache，也不重建两个秘密 share。

输入为两个 1600-bit share、64-bit RC 和 token，使用 in_valid/in_ready 接受。
token 默认 96 bit，由上层绑定 command_epoch、primitive_id、round_index；
随机接口 token 是随机服务完整租约经上层校验后形成的对应轮身份，不能直接忽略
随机服务的 lease/chunk 身份。ROUND 不取代上层的授权、随机 quota 或 lease 检查。

随机接口有独立 valid/ready，三个 1600-bit r/s/m 只在握手沿进入 MASK_AND
第一寄存级。random_release 为提交沿的单拍事件，携带该轮 token；租约只释放一次。
输入 RC/token 一旦接受，后续不再读输入端口。两 share 输出及 token 在背压期间
保持；接受新轮必须等待当前结果退休，不复用在途 gadget。

## 四拍数据通路

| 边沿 | 操作 | 寄存归属 |
|---|---|---|
| E0 | 接受输入，两 share 分别 theta/rho/pi | ROUND.linear0/linear1 与 RC/token |
| E1 | 随机身份匹配且 valid/ready，chi 的两输入进入 HPC3+ 第一寄存级 | MASK_AND |
| E2 | HPC3+ 第二寄存级 | MASK_AND |
| E3 | XOR 线性结果，RC 只注入 share0；释放随机租约 | ROUND.result0/result1 |

E1 随机输入等待可延长，等待期间线性状态和身份不变。E3 同沿清线性寄存与 RC；
RESULT 周期清 MASK_AND 的全部寄存级，不因输出背压保留已经消费的随机数。
输出退休沿清结果与 token。新的输入最早在下一 IDLE 周期接受。
NOT 只作用于 chi 输入的 share0，share1 不取反；IOTA 常量只作用于 result0。
25 lanes 按 x+5y 排列，每 lane 64-bit little-endian，状态低位为 lane (0,0)。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KECCAK.MASKED_ROUND
module_ref: LLD.MOD.PQC.KECCAK.MASKED_ROUND
input_width: 1600
output_width: 1600
operators: [independent_share_theta_rho_pi, registered_hpc3_chi, single_share_iota]
representation: two_boolean_shares_without_reconstruction
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
applicability:
  expr: SCA_LEVEL == 2
END_LLD_DATAPATH_META -->

<!-- LLD_FSM_META
id: LLD.FSM.PQC.KECCAK.MASKED_ROUND
module_ref: LLD.MOD.PQC.KECCAK.MASKED_ROUND
encoding: onehot
reset_state: IDLE
states: [IDLE, CHI_REQ, CHI_WAIT, RESULT]
illegal_state_handling: fatal
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: SCA_LEVEL == 2
transitions:
- {source: IDLE, destination: CHI_REQ, condition: input_fire}
- {source: CHI_REQ, destination: CHI_WAIT, condition: matched_random_fire}
- {source: CHI_WAIT, destination: RESULT, condition: matched_gadget_commit}
- {source: RESULT, destination: IDLE, condition: result_fire}
- {source: IDLE, destination: IDLE, condition: clear_or_fault_priority}
- {source: CHI_REQ, destination: IDLE, condition: clear_or_fault_priority}
- {source: CHI_WAIT, destination: IDLE, condition: clear_or_fault_priority}
- {source: RESULT, destination: IDLE, condition: clear_or_fault_priority}
END_LLD_FSM_META -->

## 故障与清除

zeroize 组合关闭所有握手、release 与结果，下一沿清本地数据和 gadget。
zeroize_done 要求本地与 gadget 的实际清除应答同时有效，不能仅依据 FSM=IDLE。
随机 token 或 gadget 返回 token 错误、非法 FSM 组合关闭输出，锁存 fault。
故障检测沿清本地数据，随后一沿清 gadget；fault 锁存到冷复位，普通 clear 不解锁。
正常错误不得发 random_release 冒充成功消费，需由全局 clear 撤销相应租约。
这两个 share 的 RTL 功能实现不等于迭代组合安全、综合网表或物理泄漏签核。

<!-- RTL_MAP_META
id: RTL.PQC.KECCAK.MASKED_ROUND
rtl_file: rtl/pqc_keccak_masked_round.sv
rtl_module: pqc_keccak_masked_round
implements:
- LLD.MOD.PQC.KECCAK.MASKED_ROUND
- LLD.DP.PQC.KECCAK.MASKED_ROUND
- LLD.FSM.PQC.KECCAK.MASKED_ROUND
END_RTL_MAP_META -->
