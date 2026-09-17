# PQC 内部接口与事务边界

## 内部接口组

| ID | Source | Destination | Type | Purpose |
|---|---|---|---|---|
| HLD.IF.INT.PQC.DESC | DMA | FE | bus | descriptor 抓取 |
| HLD.IF.INT.PQC.DISPATCH | FE | KEMSEQ/DSASEQ | command | 已校验命令派发 |
| HLD.IF.INT.PQC.COMPL | KEMSEQ/DSASEQ | FE | status | completion 汇聚 |
| HLD.IF.INT.PQC.PRIM | KEMSEQ/DSASEQ | POLY/KECCAK/SAMPLER/CODEC | command | primitive 派发 |
| HLD.IF.INT.PQC.PAGE | SEQ/POLY/SAMPLER/CODEC | SRAM | memory | 系数页与 metadata |
| HLD.IF.INT.PQC.DMABUF | DMA | SRAM | memory | packed buffer |
| HLD.IF.INT.PQC.SQZ | KECCAK | SAMPLER | stream | squeeze 字节流 |
| HLD.IF.INT.PQC.STAGE | DSASEQ | DMA | stream | 原子 commit |
| HLD.IF.INT.PQC.KEY | KEYSLOT | KEMSEQ/DSASEQ | reference | 私钥引用 |
| HLD.IF.INT.PQC.FAULT | FAULT | all | control | zeroize/lock/alert |

### HLD.IF.INT.PQC.DISPATCH

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.DISPATCH
name: command_dispatch
scope: internal
protocol: command
role: consumer
owner_module: HLD.MOD.PQC.FE
clock_domain: HLD.DOM.CLK.PQC.CORE
req_ref:
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

把通过全部校验的命令派发给对应算法序列控制器。

#### Supported Architectural Capabilities

- opcode/parameter set/flags/地址/长度/key handle/context 传递；
- BUSY 锁定语义。

#### Unsupported Capabilities

- 传递未校验的原始 descriptor 字段。

---

### HLD.IF.INT.PQC.PRIM

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.PRIM
name: primitive_dispatch
scope: internal
protocol: command
role: producer
owner_module: HLD.MOD.PQC.KEMSEQ
clock_domain: HLD.DOM.CLK.PQC.CORE
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.PERF.PQC.NOSW.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

序列控制器向共享 primitive 派发带 source/destination page、mode 与 dependency token 的
内部指令，由 scoreboard 管理 KECCAK/NTT/SAMPLER/CODEC/DMA 四类资源。

#### Supported Architectural Capabilities

- 静态已审计的重叠（Keccak/NTT、DMA/Keccak、codec/MAC）；
- 公开 loop bound。

#### Unsupported Capabilities

- secret-dependent predicate 发射/取消 primitive。

---

### HLD.IF.INT.PQC.PAGE

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.PAGE
name: page_access
scope: internal
protocol: memory
role: master
owner_module: HLD.MOD.PQC.SRAM
clock_domain: HLD.DOM.CLK.PQC.CORE
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.SEC.PQC.CT.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

以 256 系数 polynomial 为基本页的访问接口，含 page metadata 与 tag check。

#### Supported Architectural Capabilities

- 双计算端口 + 一个 DMA 端口；
- bank 化避免 butterfly 冲突；
- SECDED ECC；
- representation 标记（COEFF_STD/NTT_STD；LAZY/MONT 仅在显式范围/比例转换合同成立时可使用）。

#### Unsupported Capabilities

- 混用不同 representation 的页；
- debug 读取 secret 页。

---

### HLD.IF.INT.PQC.STAGE

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.STAGE
name: signature_staging
scope: internal
protocol: stream
role: producer
owner_module: HLD.MOD.PQC.DSASEQ
clock_domain: HLD.DOM.CLK.PQC.CORE
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

候选签名的不可见 staging 通道，仅在全部检查通过后允许 commit。

#### Supported Architectural Capabilities

- 原子 commit；
- 失败 attempt 不可见。

#### Unsupported Capabilities

- 部分签名的增量可见性。

---

### HLD.IF.INT.PQC.FAULT

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.FAULT
name: fault_control
scope: internal
protocol: control
role: producer
owner_module: HLD.MOD.PQC.FAULT
clock_domain: HLD.DOM.CLK.PQC.CORE
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.LOCK.001
- LRS.RESET.PQC.SAFE.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

#### Interface Role

向全部模块广播 zeroize/lock/alert 控制。

#### Supported Architectural Capabilities

- 从任意状态异步请求 zeroize；
- 有界完成。

#### Unsupported Capabilities

- 被主 FSM 阻塞的 zeroize。

## HLD.IF.INT.PQC.DESC

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.DESC
name: descriptor_shadow
scope: internal
protocol: stream
role: producer
owner_module: HLD.MOD.PQC.DMA
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.FUNC.PQC.CMD.002
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

描述符读取独占一个读事务身份，按全局偏移装入固定 128 B shadow；末拍/长度错误终止解析。抓取期间主机必须不修改描述符，抓取完成后命令只消费 shadow。取消不能撤销已发 AXI VALID，须排空已接受事务。


## HLD.IF.INT.PQC.COMPL

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.COMPL
name: operation_completion
scope: internal
protocol: transaction
role: consumer
owner_module: HLD.MOD.PQC.FE
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.REG.PQC.COMPLETION.001
- LRS.FUNC.PQC.CMD.006
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

算法结果只表示可进入 commit。FE 等待全部输出写响应及必要 Key Manager ACK，再发 completion record；completion 写响应成功后才更新成功状态及 DONE IRQ。任一写响应失败则保留错误且不能发布成功。返回长度只统计实际已承诺的输出。


## HLD.IF.INT.PQC.DMABUF

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.DMABUF
name: public_dma_buffer
scope: internal
protocol: memory
role: slave
owner_module: HLD.MOD.PQC.SRAM
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.SEC.PQC.SLOT.005
- LRS.INTF.PQC.DMA.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

DMA 只访问显式公开输入/获准输出页，按命令 epoch、范围、方向授权；可控主机地址不能转译成工作态 Key RAM 地址。尾字节 mask 生效，未写 word 不可读。shared secret 仅经特权安全输出 grant，可完成即退休，不把 secret 页整体改成公开页。


## HLD.IF.INT.PQC.SQZ

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.SQZ
name: squeeze_stream
scope: internal
protocol: stream
role: producer
owner_module: HLD.MOD.PQC.KECCAK
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

绑定函数、context、输出消费者及剩余字节数；背压不丢失/重复字节，换块后续接同一 XOF 状态。更换消费者或函数必须结束原事务或显式清除，不可把旧 squeeze 当作新输入。


## HLD.IF.INT.PQC.KEY

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.KEY
name: key_authorization
scope: internal
protocol: authorization
role: producer
owner_module: HLD.MOD.PQC.KEYSLOT
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.003
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

元数据验证返回不可伪造的命令内授权上下文，绑定完整 handle/owner/algo/pset/usage。该接口只提供授权，不提供私钥字节；与 WORKKEY 材料头交叉校验后才派发私钥命令。generation 用尽不得回绕，复位后的旧域句柄须由 Key Manager 作废。


## HLD.IF.INT.PQC.KEY_MATERIAL

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.KEY_MATERIAL
name: private_work_key_access
scope: internal
protocol: secure_memory
role: slave
owner_module: HLD.MOD.PQC.WORKKEY
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

只面向当前授权 sequencer，读取地址为私钥内相对偏移；越界、未就绪、ECC 不可纠正或命令 epoch 失效均不返回有效材料。材料在私钥解码后只能写 secret-tag 工作页。KeyGen 编码写端口与导入端口互斥，托管读端口不得读取导入态密钥；普通 DMA 没有路由。
