# ML-DSA Sign 集成验证增量

<!-- TESTCASE_META
id: TC.PQC.DSA.SIGN.MAIN.001
name: tc_dsa_sign_main
type: directed
description: pure ML-DSA三参数集确定性、重复及hedged签名与独立oracle逐字节比对
priority: must
tier: regression
implementation: verification/tc/tc_dsa_sign_main.sv
proof_kind: uvm
feature_ref: [FL.PQC.ALGO]
design_ref: [LLD.MOD.PQC.DSASEQ.SIGN]
preconditions:
- 离线冻结dilithium-py 1.4.0独立向量及固定RTL，SCA_LEVEL小于2
stimulus:
- 每参数集三个独立私钥经专用KM导入；message为0/137/65537B，context为0/1/255B
- 每组执行确定性、32B固定rnd的hedged、再次确定性三次签名
- AXI背压和延迟B响应，实际消息分块DMA、片内SHAKE和拒绝重试
expected_result:
- 二十七个签名的所有字节与独立冻结oracle相等；oracle独立验证签名有效
- 确定性两次完全一致且消费0B随机，hedged恰好消费32B随机
- 所有读取仅描述符、message/context；私钥不经过公共DMA
- 签名输出恰好一次且不越界，签名B响应先于completion，completion B响应先于IRQ
- 每次正常尝试在公开pset决定的固定周期边界（44/65为1500000，87为2250000）结束，尝试次数等于独立oracle（包括31次拒绝采样长场景）
- 完成记录所有字段与长度匹配，超时/零比较/缺少标记失败
config_ref: [CFGSET.PQC.DEFAULT]
applicability:
  expr: 'SCA_LEVEL < 2'
timeout_policy: 200000000 cycles per command; 3600 s process watchdog
END_TESTCASE_META -->

完整故障、撤销、重试耗尽、HashML-DSA与Level2义务由原VPLAN继续跟踪。
