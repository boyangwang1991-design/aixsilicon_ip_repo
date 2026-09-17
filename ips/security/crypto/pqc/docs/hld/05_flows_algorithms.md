# PQC 算法入口与安全托管数据流

以下是架构上的先后依赖；算法细节以标准为准，周期和资源表由 LLD 落实。

## HLD.FLOW.PQC.KEM_KEYGEN

<!-- HLD_FLOW_META
id: HLD.FLOW.PQC.KEM_KEYGEN
name: kem_keygen_custody
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.SEC.PQC.SLOT.008
participants:
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.WORKKEY
- HLD.MOD.PQC.DMA
applicability:
  expr: 'true'
END_HLD_FLOW_META -->

授权熵 → 派生种子 → 采样并变换秘密向量 → 逐行生成矩阵并累加 → 编码公钥/私钥。
公钥进入公开 staging；私钥进入工作态 RAM 并完成完整性检查。随后先完成专用托管确认，
再发布公钥/handle 和 completion。生成失败不得留下有效 handle。

## HLD.FLOW.PQC.KEM_ENCAPS

<!-- HLD_FLOW_META
id: HLD.FLOW.PQC.KEM_ENCAPS
name: kem_encaps
req_ref:
- LRS.FUNC.PQC.KEM_ENCAPS.001
- LRS.FUNC.PQC.KEM_LEN.001
participants:
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DMA
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.CODEC
applicability:
  expr: 'true'
END_HLD_FLOW_META -->

公共 DMA 读取并校验公钥编码 → 取得批准 randomness → 哈希派生加密随机量和共享秘密 →
生成转置矩阵与噪声并执行多项式运算 → 编码密文。密文与共享秘密使用不同安全输出授权，
输出完成后才发 completion。Encaps 不需要导入私钥 handle。

## HLD.FLOW.PQC.DSA_KEYGEN

<!-- HLD_FLOW_META
id: HLD.FLOW.PQC.DSA_KEYGEN
name: dsa_keygen_custody
req_ref:
- LRS.FUNC.PQC.DSA_KEYGEN.001
- LRS.SEC.PQC.SLOT.008
participants:
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.WORKKEY
- HLD.MOD.PQC.DMA
applicability:
  expr: 'true'
END_HLD_FLOW_META -->

授权熵 → 派生种子 → 采样秘密向量 → 矩阵行乘积及舍入 → 公钥编码/哈希与私钥编码。
私钥只进入工作态材料端口并由 Key Manager 接收；公钥/句柄提交沿用共同托管流程。

## HLD.FLOW.PQC.DSA_VERIFY

<!-- HLD_FLOW_META
id: HLD.FLOW.PQC.DSA_VERIFY
name: dsa_verify
req_ref:
- LRS.FUNC.PQC.DSA_VERIFY.001
- LRS.FUNC.PQC.DSA_MESSAGE.001
participants:
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.DSASEQ
- HLD.MOD.PQC.DMA
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SAMPLER
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.CODEC
applicability:
  expr: 'true'
END_HLD_FLOW_META -->

DMA 读取公钥与签名，消息可分块吸收；检查编码、z 范数和 hint 合法性。重建挑战并进行
矩阵/公钥多项式计算，经 UseHint 恢复高位后哈希；全长双轨摘要比较与所有合法性条件共同
决定公开 Verify 结果。不能以旧摘要或单个 primitive 的完成信号代替 Verify。

架构依据：[FIPS 203](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf)、[FIPS 204](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf)。矩阵逐行/逐多项式重放是本实现的存储取舍，需以完整 RTL KAT 验证等价性。
