# Decaps 真实数据通路集成验证

本用例验证非掩码Decaps候选，不能替代Level2、全部密文失配位置、撤销/故障及完整
算法验收用例。实际结果只在统一报告记录。

<!-- TESTCASE_META
id: TC.PQC.DECAPS.MAIN.001
name: tc_kem_decaps_main
type: directed
description: 真实Decaps正常/隐式拒绝KAT、固定公开时序比较及背压退休
priority: must
tier: regression
implementation: verification/tc/tc_kem_decaps_main.sv
proof_kind: uvm
feature_ref: [FL.PQC.ALGO]
design_ref: [LLD.MOD.PQC.KEMSEQ.DECAPS, LLD.MOD.PQC.WORKKEY, LLD.MOD.PQC.DMA]
preconditions:
- 固定源码和向量哈希，VCS UVM 1.2，SCA_LEVEL小于2
- 私钥经KM sideload导入，DUT执行全部运算，无运行时Python/C/DPI算法
stimulus:
- 三参数集各三组独立确定输入，共九组正常向量
- 各向量分别篡改密文首、中、末字节，使用离线SHAKE256(z||received_ct)冻结拒绝秘密
- 无随机外部stall时比较相同输入身份正常/失配的completion周期字段
- 九组正常向量另以周期反压和延迟B响应连续执行
expected_result:
- 45条命令的32B共享秘密逐字节相等；全部输出/完成字节恰好写一次
- 正常与合法长度失配均返回SUCCESS，不通过completion/IRQ暴露隐式拒绝标志
- 同一向量正常/失配周期相同；这不等于完整侧信道安全证明
- SS的B响应在completion地址发出前完成，completion的B响应在IRQ前完成
- 禁止DMA读取私钥，外部读范围只有描述符及密文；guard bytes保持
- 所有45个case及最终完成标记齐全，缺向量/超时/零比较不能通过
timeout_policy: 2000000 cycles per command; 600 s process watchdog
config_ref: [CFGSET.PQC.DEFAULT]
applicability:
  expr: 'SCA_LEVEL < 2'
END_TESTCASE_META -->

原六组向量ID0..5保持原字节，新第三组使用ID6..8。生成器拒绝覆盖内容不同的已冻结
向量；正常秘密由独立软件oracle离线给出，拒绝秘密另由标准SHAKE256计算并交叉核对。
测试监视实际AXI写事务、APB状态和IRQ；内部状态日志不参与正确性判定。
