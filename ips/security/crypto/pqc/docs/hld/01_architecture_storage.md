# PQC L1 模块职责

### HLD.MOD.PQC.SRAM — 安全本地 SRAM 控制器

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.SRAM
name: pqc_secure_sram_ctrl
responsibility: bank 仲裁、SECDED ECC、page tag 校验、zeroize
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.SEC.PQC.ZEROIZE.001
- LRS.RESET.PQC.SAFE.001
- LRS.DFX.PQC.MBIST.001
- LRS.CFG.PQC.LOCAL_SRAM.001
- LRS.SEC.PQC.CT.003
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.PAGE
- HLD.IF.INT.PQC.DMABUF
END_HLD_MODULE_META -->

#### Responsibility

提供至少两个计算端口加一个 DMA 端口的仲裁等效能力；维护每页 metadata
（valid/secret/representation/algorithm/parameter_set/owner_context/ecc_status）；
在 primitive dispatch 前执行 tag check；执行全容量 zeroize。

#### Architecture Role

把秘密存储、访问模式与生命周期集中到单点，使"秘密不离开安全边界"和"可证明清零"
成为可独立验证的组件性质；bank 映射避免 butterfly 两端点冲突。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.PAGE | input/output | poly/sampler/codec/sequencers | 系数页与 metadata |
| HLD.IF.INT.PQC.DMABUF | input/output | `pqc_dma` | packed buffer |

#### Non-Responsibility

- 不实现长期私钥驻留（由外部 Key Manager 承担）；
- 不实现 MBIST 控制器本身；
- 不做算法 tag 语义判定。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.KEYSLOT — 密钥槽

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.KEYSLOT
name: pqc_key_slots
responsibility: key 元数据、权限、generation、slot 锁定与清零
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.004
- LRS.REG.PQC.SLOT.001
- LRS.CFG.PQC.KEY_SLOT.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.INT.PQC.KEY
- HLD.IF.EXT.PQC.SIDEBAND
END_HLD_MODULE_META -->

#### Responsibility

维护 `{generation, owner, slot}` key handle 语义；保存 slot 元数据；提供 secure-only
管理窗口；默认拒绝私钥读出；destroy/reallocate 时递增 generation 并使旧 handle 失效。

#### Architecture Role

长期所有权由外部 Key Manager 决定，本模块是授权元数据镜像。工作态材料由独立
Key RAM 管理；只有两者绑定一致才允许算法消费，任何一方失效都不能继续使用。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.INT.PQC.KEY | output | sequencers | 私钥引用（无明文导出路径） |
| HLD.IF.EXT.PQC.SIDEBAND | input | key manager/lifecycle | 导入与生命周期 |

#### Non-Responsibility

- 不在普通工作 SRAM 保存长期私钥；
- 不实现 key wrap；
- 不做算法运算。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.DMA — 数据搬运

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.DMA
name: pqc_dma
responsibility: AXI4 master 搬运、4 KiB 合规、范围检查、分段拼装
req_ref:
- LRS.INTF.PQC.DMA.001
- LRS.INTF.PQC.DMA.002
- LRS.INTF.PQC.DMA.003
- LRS.SEC.PQC.SLOT.005
- LRS.CFG.PQC.DMA_WIDTH.001
- LRS.PERF.PQC.OVERLAP.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.EXT.PQC.DMA
- HLD.IF.INT.PQC.DESC
- HLD.IF.INT.PQC.DMABUF
- HLD.IF.INT.PQC.STAGE
END_HLD_MODULE_META -->

#### Responsibility

生成 INCR burst 且遵守 4 KiB 边界；携带安全/特权属性；执行 IP 内部地址范围与容量检查；
对分段输入做无损拼装使结果与连续输入等价。

#### Architecture Role

把外部内存访问与内部存储解耦，并作为分段等价性与 DMA 安全属性的实施点。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.EXT.PQC.DMA | output | SoC 内存 | 数据搬运 |
| HLD.IF.INT.PQC.DESC | output | `pqc_cmd_frontend` | descriptor 抓取 |
| HLD.IF.INT.PQC.DMABUF | input/output | `pqc_secure_sram_ctrl` | packed buffer |
| HLD.IF.INT.PQC.STAGE | input | `pqc_dsa_seq` | 原子 commit |

#### Non-Responsibility

- 不做 SoC 级 IOMMU 判定；
- 不做 scatter-gather（V1.0 仅线性 buffer）；
- 不做算法语义检查。

---



该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。

### HLD.MOD.PQC.FAULT — 故障与零化控制

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.FAULT
name: pqc_fault_ctrl
responsibility: alert 汇聚、冗余/奇偶校验、zeroize 序列、锁定
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
- LRS.SEC.PQC.LOCK.001
- LRS.SEC.PQC.INTEGRITY.001
- LRS.SEC.PQC.VERIFY.001
- LRS.RESET.PQC.SAFE.001
- LRS.DFX.PQC.FI.001
- LRS.INTF.PQC.SIDEBAND.001
- LRS.RESET.PQC.COLD.001
- LRS.RESET.PQC.WARM.001
- LRS.RESET.PQC.POWERDOWN.001
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.EXT.PQC.SIDEBAND
- HLD.IF.INT.PQC.FAULT
END_HLD_MODULE_META -->

#### Responsibility

汇聚 tamper/fatal ECC/self-test fail/lifecycle 变化/DMA error/timeout/RNG health，
触发统一安全收尾；执行同步 `zeroize_req`；对控制 FSM、opcode、参数集、key type、
权限字段、关键计数器与 micro-PC 提供完整性检查。

#### Architecture Role

故障与零化路径独立于主数据通路与时序 FSM，满足"zeroize 不依赖主 FSM 正常运行"。

#### Inputs / Outputs

| Interface Group | Direction | Peer | Purpose |
|---|---|---|---|
| HLD.IF.EXT.PQC.SIDEBAND | input | 安全子系统 | tamper/lifecycle/zeroize |
| HLD.IF.INT.PQC.FAULT | output | 所有模块 | zeroize/lock/alert |

#### Non-Responsibility

- 不执行算法运算；
- 不决定生命周期策略本身；
- 不替代 SoC 级安全控制器。

该模块另承担上述 `req_ref` 的配置、生命周期与可观测接口责任；具体验证方法归 VPLAN，
周期行为及实现映射归 LLD。当前 RTL 与此架构的差距见统一报告，不以模块名存在证明实现。


## HLD.MOD.PQC.WORKKEY 工作态安全 Key RAM

<!-- HLD_MODULE_META
id: HLD.MOD.PQC.WORKKEY
name: pqc_work_key_ram
responsibility: 工作态私钥专用导入、完整性、授权读取、KeyGen 暂存/安全托管与物理擦除
req_ref:
- LRS.INTF.PQC.KEY_MANAGER.001
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
applicability:
  expr: 'true'
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
power_domain: HLD.DOM.PWR.PQC.CORE
interfaces:
- HLD.IF.EXT.PQC.KEY_MANAGER
- HLD.IF.INT.PQC.KEY_MATERIAL
- HLD.IF.INT.PQC.FAULT
END_HLD_MODULE_META -->

长期所有权、授权域和句柄分配来自外部 Key Manager。PQC 一次仅保留一个工作态私钥，
8 KiB 容量独立于 LOCAL_SRAM_KIB，也独立于逻辑 slot 数；容纳最大 4896 B 编码私钥。
完整导入并验证 ECC/长度后发布 READY；材料读取只允许当前被派发命令绑定的
完整 handle、owner/domain、算法、参数与用途。普通 CSR/DMA/PIO/debug 没有此访问端口。

KeyGen 把私钥编码写到工作态 RAM，只有本次新生成且尚未退休的材料可进入专用托管方向。
外部接收方须确认事务身份、长度与安全接收；成功确认前不发布 handle 或成功 completion。
导入的已有私钥不能被通用读回命令或伪造 KeyGen 状态转为托管输出。

撤销与故障立即关闭权限；擦除覆盖 RAM、ECC、读取暂存及托管缓冲。擦除与总线排空分别
确认，不把超时当作成功。外部密钥不会因副本退休被隐式销毁。元数据模块不再被当作材料提供者。
