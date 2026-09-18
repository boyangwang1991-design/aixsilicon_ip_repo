# DSA Verify 真实数据链（candidate）

依据 [FIPS 204 Algorithm 3/8](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf)，
验证必须从外部message/context/public key/signature计算mu与重建挑战，不接受host提供内部mu。
本程序首先覆盖pure ML-DSA三参数集；HashML-DSA与完整Level2/故障组合义务仍不由此自动关闭。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.DSASEQ.VERIFY
name: pqc_dsa_verify
parent_ref: LLD.MOD.PQC.DSASEQ
hld_ref: [HLD.MOD.PQC.DSASEQ]
req_ref: [LRS.FUNC.PQC.DSA_VERIFY.001]
clock_domains: [HLD.DOM.CLK.PQC.CORE]
reset_domains: [HLD.DOM.RST.PQC.MAIN]
rtl_intent:
  separate_module: true
  suggested_name: pqc_dsa_verify
END_LLD_MODULE_META -->

TOP先DMA读src1的pk||signature及context；输入长度由公开描述符验证。
程序解码rho、ctilde、z和hint，检查hint累计边界/行内严格递增/尾部零及z严格norm。
tr=SHAKE256(pk,64)，mu=SHAKE256(tr||0||ctx_len||ctx||message,64)。
消息按最多1024B分块DMA至单页，在Keccak吸收中背压；长度与游标为64bit，不按SRAM容量截断。

使用既有domain=DSA的poly/sampler/codec：NTT(z)、SampleInBall(ctilde)、NTT(c)，
逐行ExpandA(rho||col||row)，计算INTT(A*z-c*NTT(t1*8192))，UseHint后打包w1。
最后SHAKE256(mu||w1Encode,ctilde_bytes)，按全长AND相等与OR差异两条路径比较。
公开无效签名完成为VERIFY_INVALID；工具/存储/超时错误不能伪装为数学invalid。

| 页 | 用途 |
|---|---|
| 0–6 | z_hat |
| 7 | 累加与INTT结果 |
| 8 | 矩阵临时多项式 |
| 9 | c_hat |
| 10 | -t1*8192及UseHint结果复用 |
| 11 | 本行hint展开 |
| 12 | bitpack/unpack临时页 |
| 13–14 | w1编码 |
| 17–24 | 不可变pk||signature输入 |
| 27 | context，最长255B |
| 28 | message分块，最多1024B |
| 23 | 仅在全部输入消费完成之后复用为completion |

全部页落在32KiB以内。命令串行，DMA与运算的内存端口遵循已有响应归属。
完成记录写status/verify_valid，等待B响应后才通知FE退休并置IRQ；前一条结果不得泄漏到本条。

<!-- RTL_MAP_META
id: RTL.PQC.DSA_VERIFY
rtl_file: rtl/pqc_dsa_verify.sv
rtl_module: pqc_dsa_verify
implements: [LLD.MOD.PQC.DSASEQ.VERIFY]
END_RTL_MAP_META -->
