# 7. 算法、模型、RTL 与测试怎样对应

[教学手册目录](index.md) · 下一章：[时序与波形](08-timing-waveforms.md)

学习时不要只问“有没有这个模块”，还要问“谁调用它，测到哪一层”。本项目的完整 Python 算法封装与底层硬件实验模型是两条路径。[accelerator.py](../../pqc_accel_model/src/pqc_hw_model/accelerator.py) 调用外部算法库；它没有把自己的 NTT、Sampler、SRAM 串起来执行完整算法。因此高层互操作通过不能证明底层模型或 RTL 的每个中间量正确。

## 四层对照表

下表的测试列表示阅读入口，不表示本次重新执行或全部通过。RTL 文件存在也不等于顶层集成、安全流程和覆盖已经完成。

| 算法概念 | Python / 独立参考入口 | RTL 入口（均位于 rtl/） | 测试与比对对象 |
|---|---|---|---|
| 完整 KEM、DSA API | [accelerator.py](../../pqc_accel_model/src/pqc_hw_model/accelerator.py) | [pqc_top.sv](../../rtl/pqc_top.sv)、kem_seq、dsa_seq | [test_algorithms.py](../../pqc_accel_model/tests/test_algorithms.py)：编码长度、互操作、篡改行为 |
| 模运算与负循环乘法 | [modular.py](../../pqc_accel_model/src/pqc_hw_model/modular.py) | [pqc_poly_engine.sv](../../rtl/pqc_poly_engine.sv) | [poly UT](../../verification/unit_test/ut_pqc_poly_engine.sv)：边界系数、各操作、内存结果 |
| NTT / INTT | [ntt.py](../../pqc_accel_model/src/pqc_hw_model/ntt.py) | pqc_poly_engine | [test_primitives.py](../../pqc_accel_model/tests/test_primitives.py)：可逆性；仍需标准中间向量确认排序与缩放 |
| SHA3 / SHAKE | [keccak.py](../../pqc_accel_model/src/pqc_hw_model/keccak.py) | [pqc_keccak.sv](../../rtl/pqc_keccak.sv) | [keccak UT](../../verification/unit_test/ut_pqc_keccak.sv)：模式、长度、已知答案 |
| 拒绝采样 / CBD | 模型包无独立 sampler 模块；可读 [oracle 的 matrix/noise](../../scripts/encaps_algebra_oracle.py) | [pqc_sampler.sv](../../rtl/pqc_sampler.sv) | [sampler UT](../../verification/unit_test/ut_pqc_sampler.sv)：相同输入字节得到相同系数与消耗量 |
| 压缩、编码 | [codec.py](../../pqc_accel_model/src/pqc_hw_model/codec.py) | [pqc_codec.sv](../../rtl/pqc_codec.sv) | [codec math UT](../../verification/unit_test/ut_pqc_codec_math.sv)：舍入、位序、非法编码 |
| Encaps 数据依赖 | [encaps_algebra_oracle.py](../../scripts/encaps_algebra_oracle.py) | [pqc_kem_encaps.sv](../../rtl/pqc_kem_encaps.sv) | [Encaps 测试矩阵](../verification/test_matrix_encaps.md)、[冻结向量 manifest](../../verification/vectors/encaps/manifest.json) |
| 描述符到命令 | [descriptor.py](../../pqc_accel_model/src/pqc_hw_model/descriptor.py) | [pqc_desc_validate.sv](../../rtl/pqc_desc_validate.sv)、cmd_frontend | [descriptor UT](../../verification/unit_test/ut_pqc_desc_validate.sv)：CRC、长度、权限等分别覆盖 |
| SRAM 权限与清零 | [memory.py](../../pqc_accel_model/src/pqc_hw_model/memory.py) | [pqc_secure_sram_ctrl.sv](../../rtl/pqc_secure_sram_ctrl.sv) | [SRAM UT](../../verification/unit_test/ut_pqc_secure_sram_ctrl.sv)：握手、访问拒绝、ECC、zeroize |
| 取消与故障传播 | 无完整周期级对应物 | fault_ctrl、DMA、各引擎 clear | [engine cancel UT](../../verification/unit_test/ut_pqc_engine_cancel.sv)、[DMA cancel UT](../../verification/unit_test/ut_pqc_dma_cancel.sv) |

## 用一个失配定位问题

假设密文的第一个字节不一致。先确认公钥、m、参数集完全相同，再按以下检查点逐层缩小范围：

1. 比 `H(ek)` 与 G 的 64 B 输出。不同通常先查哈希模式、输入拼接和字节顺序。
2. 比采样出的 y。不同先查 nonce、eta、CBD 位顺序，不能直接责怪 NTT。
3. 比 y_hat 时先统一域、系数顺序和缩放。不同表示的数组可能表达同一个数学对象。
4. 比第一行矩阵乘积的逆 NTT 结果。检查转置下标、KEM 配对基乘法和模约减。
5. 比加噪声后的系数、压缩整数、最终编码字节。由此区分舍入错误与 packing 错误。
6. 算法结果一致而系统内存不同，转查 DMA 地址、字节选通和完成提交。

做调试 trace 时固定使用公开测试种子；真实运行的 m、r、y、K 和私钥中间量都不应写入普通日志。

## 需要独立补证的边界

| 已知现象 | 能得出的结论 | 还不能得出的结论 |
|---|---|---|
| NTT→INTT 恢复输入 | 两个函数相互匹配 | 与标准排列一致；配套乘法正确 |
| 两个实现密文相同 | 对该输入功能一致 | 故障、背压、随机健康和秘密泄漏安全 |
| primitive UT 通过 | 被测试的局部行为符合预期 | 整条命令从 AXI 输入到 completion 正确 |
| trace 的公开 shape 相同 | 记录的几个字段相同 | 实际 RTL 常数时间或抗功耗分析 |
| 新增 keygen/sign/verify 源文件 | 已有候选实现可阅读 | 当前报告已经覆盖这些新增路径 |

当前证据查[统一报告](../../reports/report.md)及其绑定文件；本教材不替代报告。检查题：为什么同一个库同时生成预期结果和运行被测算法会减弱证据？因为两边可能共享同一个错误；独立环乘法 oracle 能减少对同一套 NTT 实现的依赖，但仍不等于标准认证。
