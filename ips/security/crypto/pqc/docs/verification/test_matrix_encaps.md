# 首条 Encaps RTL/UVM 验证

<!-- TESTCASE_META
id: TC.PQC.ENCAPS.MAIN.001
name: tc_kem_encaps_main
type: algorithm
description: 首条真实Encaps集成路径，三参数集各两组冻结KAT及连续命令
priority: must
tier: smoke
implementation: verification/tc/tc_kem_encaps_main.sv
proof_kind: uvm
feature_ref:
- FL.PQC.ALGO
design_ref:
- LLD.MOD.PQC.KEMSEQ.ENCAPS
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.DMA
preconditions:
- CFG_BALANCED；kyber-py 1.2.0离线冻结hex及manifest哈希通过；实际RTL计算，无运行时算法DPI
stimulus:
- 通过APB VIP提交128B CRC描述符；外部AXI内存提供真实公钥；entropy接口重放32B m
- 三参数集各两组，六条连续命令；AR/R/AW/W周期性停顿，B延迟17/20/23/26/29/32周期
expected_result:
- AXI monitor逐有效WSTRB检查密文全部字节与32B秘密，拒绝重复字节、越界、漏字节和提前completion
- 输出B全部成功后才允许completion写；completion B成功后才允许IRQ；核验全部32B记录与输出guard字节
- 每命令entropy恰4次握手，输入读取128+pk_bytes，六条CASE_PASS与MAIN_PASS，UVM_ERROR/FATAL为0
timeout_policy: 2000000 cycles per command; 180 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: SCA_LEVEL == 1
END_TESTCASE_META -->

本用例只关闭Encaps正向主通路的有限向量义务。完整KEM三操作、非法输入/总线错误、
ML-DSA、Level2、安全策略与全配置仍由原矩阵负责，不因本用例通过而标记完成。
冻结向量在verification/vectors/encaps；生成器只用于离线准备，不在run_uvm流程运行。
APB使用外部VIP；128-bit/40-bit reduced AXI目前使用IP侧适配器pqc_main_if。
适配器不是完整AXI VIP资格证据。monitor由UVM测试独立解读握手及地址，不读取DUT SRAM。
