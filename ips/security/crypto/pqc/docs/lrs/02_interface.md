# PQC LRS：接口需求

本 IP 对外接口分为控制面（APB4 slave）、数据面（AXI4 master）与旁带（中断、
entropy、key-manager、lifecycle、tamper、zeroize）。旁带协议由系统集成层定义，本 LRS 只规定
IP 侧可观察行为。

## 接口概览

| Interface | Direction | Protocol | Clock | Reset | Configuration |
|---|---|---|---|---|---|
| `apb` | Slave | APB4 32-bit | `clk` | `rst_n` | always |
| `dma` | Master | AXI4 64/128/256-bit | `clk` | `rst_n` | `DMA_DATA_WIDTH` |
| `pio` | Slave | valid/ready byte stream | `clk` | `rst_n` | `ENABLE_PIO` |
| `key_manager` | 专用双向 | 授权导入/KeyGen 托管/撤销 | `clk` | `rst_n` | always |
| `entropy` | Slave | valid/ready + domain tag | `clk` | `rst_n` | always |
| `lifecycle` | Input | static straps | async | - | always |
| `tamper` | Input | level | async | - | always |
| `zeroize_req` | Input | level | async | - | always |
| `irq` | Output | level | `clk` | `rst_n` | always |

### LRS.INTF.PQC.APB.001 APB4 控制接口协议

<!-- LRS_META
id: LRS.INTF.PQC.APB.001
category: INTF
feature: apb
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.1
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

控制接口应为 APB4 slave，32 bit 数据宽度，寄存器自然对齐。应支持读取 ID/能力/状态/
结果/错误，写入控制/命令/描述符地址/key handle/中断控制。

应处理 APB4 的 PPROT/PSTRB；不支持 APB5 专属扩展或 burst 传输；非法地址访问应由默认从端返回
错误响应而不挂死总线。

#### Acceptance Criteria

- 所有合法寄存器读写符合 APB4 时序；
- 未定义地址返回 PSLVERR 且不产生副作用；
- DUT 不产生违反 APB4 的协议输出。

---

### LRS.INTF.PQC.DMA.001 AXI4 master 数据接口协议

<!-- LRS_META
id: LRS.INTF.PQC.DMA.001
category: INTF
feature: dma_axi
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.1
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

数据接口应为 AXI4 master，数据宽度由 `DMA_DATA_WIDTH` 定义，使用 INCR burst，
遵守 4 KiB 边界，支持 outstanding 但同一 buffer 内保序。

明确不支持：FIXED/WRAP burst、exclusive access、cache 属性修改。

#### Acceptance Criteria

- 所有生成的 burst 满足 4 KiB 边界与 INCR 语义；
- 同一 buffer 的传输按提交顺序完成；
- 不支持属性不被发出。

---

### LRS.INTF.PQC.DMA.002 DMA 数据宽度

<!-- LRS_META
id: LRS.INTF.PQC.DMA.002
category: INTF
feature: dma_axi
priority: P1
status: active
source_ref:
- pqc_contract.md#§8.1
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

#### Requirement

DMA 数据宽度应由 `DMA_DATA_WIDTH` 定义，支持 `{64, 128, 256}` bit。地址宽度应支持
至少 40 bit，以覆盖安全 SoC 地址空间。

#### Acceptance Criteria

- 所有合法宽度可正确拆分/合并传输；
- 非支持宽度无法 elaboration；
- 地址高位可被软件配置且不被截断。

---

### LRS.INTF.PQC.DMA.003 DMA 分段输入等价性

<!-- LRS_META
id: LRS.INTF.PQC.DMA.003
category: INTF
feature: dma_axi
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.3
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DMA 分段输入不得改变算法结果。任意合法分段边界（含非 4 KiB 对齐、非 DMA 宽度整数倍
的尾部）应产生与单次连续传输字节级相同的结果。

#### Acceptance Criteria

- 同一消息以多种分段方式输入得到相同签名/摘要；
- 尾部不满一个 beat 的 keep 处理正确；
- 分段不改变 constant-time 性质。

---

### LRS.INTF.PQC.ENTROPY.001 熵接口

<!-- LRS_META
id: LRS.INTF.PQC.ENTROPY.001
category: INTF
feature: entropy
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.3
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

熵接口应为 valid/ready 握手并提供 health status 与 domain tag。硬件只能在授权的
生命周期/策略组合下消费该接口；KAT 测试 seed 只能在允许的测试模式使用。

#### Acceptance Criteria

- 熵请求仅在合法策略下发出；
- health 异常时请求停止；
- domain tag 与命令的算法/参数集匹配。

---

### LRS.INTF.PQC.SIDEBAND.001 旁带与中断接口

<!-- LRS_META
id: LRS.INTF.PQC.SIDEBAND.001
category: INTF
feature: sideband
priority: P0
status: active
source_ref:
- pqc_contract.md#§8.1
- pqc_contract.md#§4.2
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

IP 应提供 lifecycle、tamper、`zeroize_req` 输入与 IRQ 输出。中断应包含 DONE、ERROR、
RNG_FAULT、TAMPER、SELF_TEST_FAIL 五类，并支持 enable/status/test 与 W1C 清除。

#### Acceptance Criteria

- 五类中断均可独立置位、屏蔽、清除；
- `zeroize_req` 有效时进入安全收尾路径；
- tamper 有效时中断与 status 按定义上报。

---

### LRS.INTF.PQC.CLKRESET.001 时钟与复位接口

<!-- LRS_META
id: LRS.INTF.PQC.CLKRESET.001
category: INTF
feature: clk_reset
priority: P0
status: active
source_ref:
- pqc_contract.md#§10
applicability:
  expr: 'true'
verification_method:
- simulation
- static
END_LRS_META -->

#### Requirement

IP 应使用单一主功能时钟 `clk` 与异步低有效复位 `rst_n`。所有密码数据路径为同步逻辑；
lifecycle/tamper/zeroize 输入为异步电平并做同步化处理。

#### Acceptance Criteria

- 单时钟域，不含未声明的跨时钟路径；
- 复位极性为低有效异步；
- 异步输入同步化不引入亚稳态传播。

---

### LRS.INTF.PQC.KEY_MANAGER.001 专用安全密钥接口

<!-- LRS_META
id: LRS.INTF.PQC.KEY_MANAGER.001
category: INTF
feature: key_manager
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.2
- docs/lrs/00_document_control.md#用户决定
applicability:
  expr: 'true'
verification_method:
- simulation
- assertion
END_LRS_META -->

#### Requirement

IP 应提供独立于普通 DMA 的工作态私钥导入、KeyGen 结果托管及撤销接口，
支持背压、明确的事务边界与完整接收确认。信任边界为授权外部 Key Manager；
普通软件不得通过 CSR 构造授权来源。跨时钟接入应由集成边界的明确 CDC 协议完成。

#### Acceptance Criteria

- 导入/托管均按握手计数，在背压时保持事务元数据与有效材料稳定；
- 撤销优先于新的导入或托管确认；
- 接口接入可信来源，普通 APB/AXI 主机无法绕过授权发起私钥传输；
- 未完成托管确认不能产生成功 completion。
