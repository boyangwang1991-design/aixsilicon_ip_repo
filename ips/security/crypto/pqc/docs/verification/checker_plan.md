# PQC 验证比对器与参考模型计划

## 参考模型策略

算法级正确性由**可执行软件证明**承担，而非 UVM 合成结论：

| 层次 | 参考来源 | 用途 |
|---|---|---|
| 自研硬件模型 | `pqc_accel_model`（bit-accurate primitive + 硬件可见行为） | primitive 与描述符行为对照 |
| 独立实现 A | `kyber-py` / `dilithium-py` | 六个参数集完整算法交叉验证 |
| 独立实现 B | 编译期 oracle（独立 C 实现） | 双向互操作验证 |

UVM 不承担完整算法端到端比对（避免从 verification model 直接合成 PASS）；UVM 侧
checker 只验证控制面、接口契约与安全属性。

## UVM Checker

| Checker | 作用 | 关联 assertion |
|---|---|---|
| `pqc_cmd_checker` | descriptor 校验、BUSY 锁定、completion 写序 | ASSERT.PQC.CMD.001、ASSERT.PQC.APB.001 |
| `pqc_reg_checker` | 复位值、RO/W1C、SW/HW 冲突优先序 | ASSERT.PQC.SIDEBAND.001 |
| `pqc_dma_checker` | AXI 协议、4 KiB 边界、属性携带 | ASSERT.PQC.DMA.001 |
| `pqc_fault_checker` | 故障汇聚、零化有界、锁定 | ASSERT.PQC.RESET.002、ASSERT.PQC.INTEGRITY.001 |
| `pqc_key_checker` | 权限、generation、无私有导出 | ASSERT.PQC.KEY.001 |

## Scoreboard

| Scoreboard | 比对内容 |
|---|---|
| `pqc_csr_scoreboard` | 寄存器期望值与实际读回 |
| `pqc_completion_scoreboard` | command_id/status/长度/tag 与提交一致 |
| `pqc_ct_scoreboard` | KEM 合法/非法密文的公开可观察特征一致性（无有效性区分） |

## 形式化属性

| 属性 | 目标 |
|---|---|
| NTT/INTT round-trip | 系数范围与可逆性 |
| 模约减范围证明 | lazy range 不溢出 |
| codec round-trip | pack/unpack 与压缩一致 |
| hint 性质 | MakeHint/UseHint 一致性与权重界 |
| secret taint | 秘密不控制错误码/DMA 地址/可见状态 |
| zeroize 活性 | 无死锁、有界完成 |
| FIFO 边界 | 不 overflow/underflow |

## 参考模型不接入验证环境

`04-behavioral-model` 的 Python 模型仅用于仿真探索，不接入 UVM 环境、不用于通过门禁。
算法级结论以 `TC.PQC.ALGO.001`（`proof_kind: software`）的可执行证据为准。

## 独立性声明

- `pqc_accel_model` 的 primitive、存储、描述符与 trace 代码不调用 oracle 内部函数；
- 完整算法比对使用两套独立实现，避免单实现偏差；
- 所有软件证明绑定实现路径、输入哈希、命令、工具版本与退出码。