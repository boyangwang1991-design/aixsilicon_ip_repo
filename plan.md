可以。下面我先给一版 **面向 AIXSILICON 的全量 IP Repo 清单**，目标不是只覆盖当前 SoC Studio 演示，而是按“长期可复用资产库”来规划，覆盖通用 MCU、应用处理器、AI SoC、车载、安全、功能安全、Chiplet 等方向。

优先级我建议这样定义：**P0 = 平台骨架、几乎所有 SoC 都需要，优先自研或纳管；P1 = 高频通用 IP，第二阶段重点；P2 = 专业域或高复杂度 IP，按项目推进；P3 = 特定产品/先进架构/生态扩展。**

---

# 一、P0：SoC 基础骨架，必须优先建设

| Domain     | IP                         | 建议形态         | 说明                     |
| ---------- | -------------------------- | ------------ | ---------------------- |
| Fabric     | AXI Interconnect           | Generator    | 多 Master/Slave         |
| Fabric     | AXI Crossbar               | Generator    | 高并发互联                  |
| Fabric     | AXI Mux                    | IP           | N→1                    |
| Fabric     | AXI Demux                  | IP           | 1→N                    |
| Fabric     | AXI Register Slice         | IP           | timing/PPA             |
| Fabric     | AXI Pipeline               | IP           | timing                 |
| Fabric     | AXI Error Slave            | IP           | Default response       |
| Fabric     | AXI Timeout Monitor        | IP           | 总线异常                   |
| Fabric     | AXI ID Remapper            | IP           | ID 管理                  |
| Fabric     | AXI Address Remapper       | IP           | 地址重映射                  |
| Bridge     | AXI→APB Bridge             | Generator    | X2P                    |
| Bridge     | AXI→AHB Bridge             | IP           | X2H                    |
| Bridge     | AHB→AXI Bridge             | IP           | H2X                    |
| Bridge     | AHB→APB Bridge             | IP           | H2P                    |
| Bridge     | AXI4→AXI4-Lite             | IP           | 协议转换                   |
| Bridge     | AXI Width Converter        | IP           | 数据宽度                   |
| APB        | APB Interconnect           | Generator    | P2P                    |
| APB        | APB Mux                    | IP           |                        |
| APB        | APB Demux                  | IP           |                        |
| APB        | APB Error Slave            | IP           |                        |
| APB        | APB Timeout                | IP           |                        |
| CDC        | AXI CDC Bridge             | IP           | Async clock            |
| CDC        | APB CDC Bridge             | IP           |                        |
| CDC        | AHB CDC Bridge             | IP           |                        |
| CDC        | Register CDC Bridge        | IP           |                        |
| CDC        | Interrupt CDC Bridge       | IP           |                        |
| System     | Clock Controller           | Generator/IP |                        |
| System     | Reset Controller           | Generator/IP |                        |
| System     | CRG                        | Generator    | Clock+Reset            |
| System     | Clock Monitor              | IP           |                        |
| System     | Reset Monitor              | IP           |                        |
| System     | System Controller          | IP           |                        |
| System     | Boot Controller            | IP           |                        |
| System     | Reset Reason Controller    | IP           |                        |
| System     | Chip ID / Revision ID      | IP           |                        |
| Interrupt  | Interrupt Router           | Generator    |                        |
| Interrupt  | Interrupt Aggregator       | IP           |                        |
| Interrupt  | Interrupt Gateway          | IP           |                        |
| Interrupt  | PLIC                       | IP           | RISC-V                 |
| Interrupt  | CLINT                      | IP           | RISC-V                 |
| DMA        | Simple DMA                 | IP           |                        |
| DMA        | Multi-channel DMA          | Generator/IP |                        |
| DMA        | AXI DMA                    | IP           |                        |
| DMA        | Memory-to-Memory DMA       | IP           |                        |
| Memory     | SRAM Controller            | Generator    |                        |
| Memory     | Multi-Port SRAM Controller | Generator    |                        |
| Memory     | ROM Controller             | IP           |                        |
| Memory     | TCM Controller             | IP           |                        |
| Memory     | SRAM ECC Controller        | IP           |                        |
| Memory     | Memory Scrubber            | IP           |                        |
| Memory     | Memory Interleaver         | IP           |                        |
| Platform   | SRAM Wrapper               | Generator    | Technology abstraction |
| Platform   | ROM Wrapper                | Generator    |                        |
| Platform   | Register File Wrapper      | Generator    |                        |
| Peripheral | UART                       | IP           |                        |
| Peripheral | GPIO                       | IP           |                        |
| Peripheral | SPI Master                 | IP           |                        |
| Peripheral | SPI Slave                  | IP           |                        |
| Peripheral | I2C Master                 | IP           |                        |
| Peripheral | I2C Slave                  | IP           |                        |
| Peripheral | Timer                      | IP           |                        |
| Peripheral | Watchdog                   | IP           |                        |
| Peripheral | PWM                        | IP           |                        |
| Debug      | JTAG TAP                   | IP           |                        |
| Debug      | RISC-V Debug Module        | IP           |                        |
| Debug      | Debug Register Block       | IP           |                        |
| Debug      | Trace Buffer               | IP           |                        |
| Debug      | Performance Monitor        | IP           |                        |
| Safety     | Fault Manager              | IP           |                        |
| Safety     | Error Aggregator           | IP           |                        |
| Safety     | Safety Watchdog            | IP           |                        |
| Safety     | Register Parity Controller | IP           |                        |
| Safety     | ECC Memory Controller      | IP           |                        |
| Safety     | Error Injection Controller | IP           |                        |
| Security   | AES                        | IP           |                        |
| Security   | SHA-2                      | IP           |                        |
| Security   | HMAC                       | IP           |                        |
| Security   | TRNG                       | IP           |                        |
| Security   | Secure Boot Controller     | IP           |                        |
| Security   | OTP/eFuse Controller       | Generator/IP |                        |
| Security   | Key Manager                | IP           |                        |
| Chip       | Pinmux                     | Generator    |                        |
| Chip       | Pad Controller             | IP           |                        |
| Chip       | Strap Controller           | IP           |                        |
| Chip       | Test Mode Controller       | IP           |                        |

这一批是 **SoC Studio 最需要直接理解、生成、连接、配置的基础 IP**。

---

# 二、P1：高频通用能力，建议紧跟 P0

| Domain     | IP                            | 建议形态      | 说明                        |
| ---------- | ----------------------------- | --------- | ------------------------- |
| Fabric     | AXI Arbiter                   | IP        |                           |
| Fabric     | AXI QoS Controller            | IP        |                           |
| Fabric     | AXI Traffic Shaper            | IP        |                           |
| Fabric     | AXI Bandwidth Limiter         | IP        |                           |
| Fabric     | AXI Protocol Firewall         | IP        |                           |
| Fabric     | AXI Isolation Bridge          | IP        |                           |
| Fabric     | AXI Exclusive Monitor         | IP        |                           |
| Fabric     | AXI Outstanding Limiter       | IP        |                           |
| Fabric     | AXI Ordering Controller       | IP        |                           |
| Fabric     | Stream Interconnect           | Generator |                           |
| Fabric     | AXI-Stream Mux                | IP        |                           |
| Fabric     | AXI-Stream Demux              | IP        |                           |
| Fabric     | AXI-Stream CDC                | IP        |                           |
| APB        | APB Firewall                  | IP        |                           |
| APB        | APB Isolation Bridge          | IP        |                           |
| AHB        | AHB Interconnect              | Generator |                           |
| AHB        | AHB Mux/Demux                 | IP        |                           |
| CDC        | Event CDC Bridge              | IP        |                           |
| CDC        | Stream CDC Bridge             | IP        |                           |
| RDC        | Reset Domain Bridge           | IP        |                           |
| Power      | Power Manager                 | IP        |                           |
| Power      | Sleep Controller              | IP        |                           |
| Power      | Wakeup Controller             | IP        |                           |
| Power      | Isolation Controller          | IP        |                           |
| Power      | Retention Controller          | IP        |                           |
| Power      | Power Domain Controller       | IP        |                           |
| Power      | Power Sequencer               | IP        |                           |
| Interrupt  | AIA                           | IP        | RISC-V Advanced Interrupt |
| Interrupt  | Event Router                  | Generator |                           |
| Interrupt  | Wakeup Event Controller       | IP        |                           |
| DMA        | Scatter-Gather DMA            | IP        |                           |
| DMA        | Peripheral DMA                | IP        |                           |
| DMA        | Stream DMA                    | IP        |                           |
| DMA        | Descriptor Engine             | IP        |                           |
| DMA        | Data Mover                    | IP        |                           |
| Memory     | Scratchpad Controller         | IP        |                           |
| Memory     | Multi-bank SRAM Controller    | Generator |                           |
| Memory     | Memory QoS Controller         | IP        |                           |
| Memory     | Memory Firewall               | IP        |                           |
| Memory     | Memory BIST Wrapper           | IP        |                           |
| Memory     | Memory Repair Controller      | IP        |                           |
| Peripheral | QSPI                          | IP        |                           |
| Peripheral | OSPI                          | IP        |                           |
| Peripheral | I3C Controller                | IP        |                           |
| Peripheral | CAN                           | IP        |                           |
| Peripheral | CAN-FD                        | IP        |                           |
| Peripheral | LIN                           | IP        |                           |
| Peripheral | SD Host                       | IP        |                           |
| Peripheral | eMMC Controller               | IP        |                           |
| Peripheral | SDIO                          | IP        |                           |
| Peripheral | RTC                           | IP        |                           |
| Peripheral | Input Capture                 | IP        |                           |
| Peripheral | Output Compare                | IP        |                           |
| Peripheral | Quadrature Encoder            | IP        |                           |
| Peripheral | Mailbox                       | IP        |                           |
| Peripheral | Hardware Semaphore            | IP        |                           |
| Peripheral | Doorbell Controller           | IP        |                           |
| Debug      | Trace Funnel                  | IP        |                           |
| Debug      | Trace Replicator              | IP        |                           |
| Debug      | Timestamp Unit                | IP        |                           |
| Debug      | Bus Monitor                   | IP        |                           |
| Debug      | AXI Transaction Monitor       | IP        |                           |
| Debug      | APB Transaction Monitor       | IP        |                           |
| Debug      | Event Counter                 | IP        |                           |
| Debug      | Error Logger                  | IP        |                           |
| Safety     | Lockstep Controller           | IP        |                           |
| Safety     | Lockstep Comparator           | IP        |                           |
| Safety     | Bus Parity Monitor            | IP        |                           |
| Safety     | Bus CRC Monitor               | IP        |                           |
| Safety     | Timeout Monitor               | IP        |                           |
| Safety     | Clock Safety Monitor          | IP        |                           |
| Safety     | Reset Safety Monitor          | IP        |                           |
| Safety     | Safe-state Controller         | IP        |                           |
| Safety     | Fault Response Controller     | IP        |                           |
| Safety     | Safety Manager                | IP        |                           |
| Safety     | Diagnostic Controller         | IP        |                           |
| Security   | SHA-3                         | IP        |                           |
| Security   | RSA                           | IP        |                           |
| Security   | ECC Crypto                    | IP        |                           |
| Security   | CSRNG/DRBG                    | IP        |                           |
| Security   | Key Vault                     | IP        |                           |
| Security   | Crypto DMA                    | IP        |                           |
| Security   | Secure Mailbox                | IP        |                           |
| Security   | Anti-Rollback Controller      | IP        |                           |
| Security   | Secure Debug Controller       | IP        |                           |
| Security   | Register Firewall             | IP        |                           |
| Security   | Bus Firewall                  | IP        |                           |
| Security   | DMA Firewall                  | IP        |                           |
| Security   | Memory Protection Controller  | IP        |                           |
| DFT        | MBIST Controller              | IP        |                           |
| DFT        | LBIST Controller              | IP        |                           |
| DFT        | Scan Controller               | IP        |                           |
| DFT        | Boundary Scan Controller      | IP        |                           |
| DFT        | BIST Clock Controller         | IP        |                           |
| Chip       | GPIO Matrix                   | Generator |                           |
| Chip       | Pad Ring Adapter              | Generator |                           |
| Chip       | Package Config Controller     | IP        |                           |
| Chip       | Device Information Controller | IP        |                           |

---

# 三、P2：复杂系统与专业领域 IP

| Domain         | IP                              | 说明                  |
| -------------- | ------------------------------- | ------------------- |
| NoC            | NoC Router                      | Packet-based fabric |
| NoC            | NoC Network Interface           | NI                  |
| NoC            | NoC Crossbar                    |                     |
| NoC            | NoC QoS Manager                 |                     |
| NoC            | NoC Traffic Shaper              |                     |
| NoC            | NoC Performance Monitor         |                     |
| NoC            | NoC Firewall                    |                     |
| NoC            | AXI↔NoC Bridge                  |                     |
| NoC            | APB↔NoC Bridge                  |                     |
| Cache          | L1 Cache Controller             |                     |
| Cache          | L2 Cache Controller             |                     |
| Cache          | Shared LLC Controller           |                     |
| Cache          | Cache Maintenance Controller    |                     |
| Cache          | Snoop Filter                    |                     |
| Cache          | Directory Controller            |                     |
| Cache          | Cache Prefetcher                |                     |
| Coherency      | ACE Bridge                      |                     |
| Coherency      | ACE-Lite Bridge                 |                     |
| Coherency      | Coherency Manager               |                     |
| Memory         | DDR Controller                  |                     |
| Memory         | DDR4 Controller                 |                     |
| Memory         | DDR5 Controller                 |                     |
| Memory         | LPDDR4 Controller               |                     |
| Memory         | LPDDR5 Controller               |                     |
| Memory         | DDR Scheduler                   |                     |
| Memory         | DDR PHY Wrapper                 |                     |
| Memory         | DDR ECC Controller              |                     |
| Memory         | Address Hash/Interleave Unit    |                     |
| Memory         | Rowhammer Mitigation Controller |                     |
| MMU            | MPU                             |                     |
| MMU            | MMU                             |                     |
| MMU            | IOMMU                           |                     |
| MMU            | PMP Manager                     |                     |
| Virtualization | VM Interrupt Controller         |                     |
| Virtualization | Guest Timer                     |                     |
| Virtualization | Virtual Interrupt Router        |                     |
| CPU            | RISC-V Core                     |                     |
| CPU            | RISC-V Cluster                  |                     |
| CPU            | Core Local Controller           |                     |
| CPU            | Hart Control Block              |                     |
| CPU            | CPU PMU                         |                     |
| CPU            | CPU Trace                       |                     |
| CPU            | CPU Debug Transport             |                     |
| High-Speed IO  | Ethernet MAC                    |                     |
| High-Speed IO  | 1G Ethernet MAC                 |                     |
| High-Speed IO  | 10G Ethernet MAC                |                     |
| High-Speed IO  | USB 2.0 Controller              |                     |
| High-Speed IO  | USB 3.x Controller              |                     |
| High-Speed IO  | PCIe Controller                 |                     |
| High-Speed IO  | UFS Controller                  |                     |
| High-Speed IO  | SATA Controller                 |                     |
| High-Speed IO  | MIPI CSI Controller             |                     |
| High-Speed IO  | MIPI DSI Controller             |                     |
| High-Speed IO  | SerDes Controller               |                     |
| Automotive     | TSN Controller                  |                     |
| Automotive     | FlexRay Controller              |                     |
| Automotive     | SENT Controller                 |                     |
| Automotive     | PSI5 Controller                 |                     |
| Automotive     | Automotive Ethernet Controller  |                     |
| Automotive     | E2E Protection Engine           |                     |
| Automotive     | Sensor Interface Controller     |                     |
| Multimedia     | I2S Controller                  |                     |
| Multimedia     | TDM Controller                  |                     |
| Multimedia     | PDM Controller                  |                     |
| Multimedia     | Audio DMA                       |                     |
| Multimedia     | Display Controller              |                     |
| Multimedia     | Camera Interface                |                     |
| Multimedia     | JPEG Encoder/Decoder            |                     |
| Multimedia     | Image Resizer                   |                     |
| Multimedia     | ISP                             |                     |
| Crypto         | SM2                             |                     |
| Crypto         | SM3                             |                     |
| Crypto         | SM4                             |                     |
| Security       | PUF Controller                  |                     |
| Security       | Tamper Detector                 |                     |
| Security       | Key Ladder                      |                     |
| Security       | Secure Counter                  |                     |
| Security       | Monotonic Counter               |                     |
| Security       | Life Cycle Controller           |                     |
| Safety         | LBIST Safety Manager            |                     |
| Safety         | MBIST Safety Manager            |                     |
| Safety         | RAM Repair Safety Controller    |                     |
| Safety         | Safety Event Router             |                     |
| Safety         | Diversity Comparator            |                     |
| Safety         | End-to-End CRC Engine           |                     |
| Safety         | Fault Collection & Control Unit | FCCU 类              |
| DFT            | Analog Test Controller          |                     |
| DFT            | Memory Redundancy Analyzer      |                     |
| DFT            | Fuse Repair Controller          |                     |
| Analog Wrapper | PLL Wrapper                     |                     |
| Analog Wrapper | DLL Wrapper                     |                     |
| Analog Wrapper | ADC Wrapper                     |                     |
| Analog Wrapper | DAC Wrapper                     |                     |
| Analog Wrapper | Temperature Sensor Wrapper      |                     |
| Analog Wrapper | Voltage Monitor Wrapper         |                     |
| Analog Wrapper | Oscillator Wrapper              |                     |
| PHY Wrapper    | PCIe PHY Wrapper                |                     |
| PHY Wrapper    | USB PHY Wrapper                 |                     |
| PHY Wrapper    | Ethernet PHY Wrapper            |                     |
| PHY Wrapper    | MIPI PHY Wrapper                |                     |

---

# 四、P3：先进架构、AI、Chiplet 与产品特定 IP

| Domain      | IP                               | 说明 |
| ----------- | -------------------------------- | -- |
| Coherency   | CHI Interface                    |    |
| Coherency   | CHI Router                       |    |
| Coherency   | CHI Home Node                    |    |
| Coherency   | CHI Request Node                 |    |
| Coherency   | CHI Slave Node                   |    |
| Coherency   | Distributed Snoop Filter         |    |
| Coherency   | Coherent NoC                     |    |
| Memory      | HBM Controller                   |    |
| Memory      | HBM PHY Wrapper                  |    |
| Memory      | CXL Memory Controller            |    |
| Memory      | Memory Compression Engine        |    |
| Memory      | Memory Encryption Engine         |    |
| Memory      | Persistent Memory Controller     |    |
| Chiplet     | UCIe Controller                  |    |
| Chiplet     | Die-to-Die Adapter               |    |
| Chiplet     | Link Training Controller         |    |
| Chiplet     | Retry Controller                 |    |
| Chiplet     | Die-to-Die CRC                   |    |
| Chiplet     | Chiplet Mailbox                  |    |
| Chiplet     | Chiplet Discovery Controller     |    |
| Chiplet     | Die ID Controller                |    |
| Chiplet     | Inter-die Interrupt Bridge       |    |
| Chiplet     | Inter-die CDC Adapter            |    |
| AI          | Matrix Multiply Accelerator      |    |
| AI          | Systolic Array                   |    |
| AI          | Tensor Core                      |    |
| AI          | Convolution Accelerator          |    |
| AI          | Attention Accelerator            |    |
| AI          | Vector Accelerator               |    |
| AI          | Sparse Accelerator               |    |
| AI          | Quantization Engine              |    |
| AI          | Dequantization Engine            |    |
| AI          | Activation Engine                |    |
| AI          | AI Scratchpad Controller         |    |
| AI          | Tensor DMA                       |    |
| AI          | Weight DMA                       |    |
| AI          | Accelerator Descriptor Engine    |    |
| AI          | Accelerator Scheduler            |    |
| AI          | Accelerator Interrupt Aggregator |    |
| AI          | Stream Fabric                    |    |
| DSP         | FFT Accelerator                  |    |
| DSP         | FIR Accelerator                  |    |
| DSP         | IIR Accelerator                  |    |
| DSP         | CORDIC                           |    |
| DSP         | DCT Accelerator                  |    |
| DSP         | CRC Accelerator                  |    |
| Multimedia  | H.264 Codec                      |    |
| Multimedia  | H.265 Codec                      |    |
| Multimedia  | AV1 Codec                        |    |
| Multimedia  | Video Scaler                     |    |
| Multimedia  | GPU Interface                    |    |
| Network     | Packet Parser                    |    |
| Network     | Packet Classifier                |    |
| Network     | QoS Scheduler                    |    |
| Network     | Traffic Manager                  |    |
| Network     | MACsec Engine                    |    |
| Network     | IPsec Engine                     |    |
| Power       | DVFS Controller                  |    |
| Power       | AVS Controller                   |    |
| Power       | Thermal Manager                  |    |
| Power       | Adaptive Clocking Controller     |    |
| Power       | Droop Monitor                    |    |
| Power       | Droop Mitigation Controller      |    |
| Reliability | ECC Telemetry Controller         |    |
| Reliability | Reliability Monitor              |    |
| Reliability | Aging Monitor                    |    |
| Reliability | Soft Error Counter               |    |
| Reliability | SRAM Patrol Controller           |    |
| Test        | Silicon Health Monitor           |    |
| Test        | In-field Test Controller         |    |
| Test        | Production Test Controller       |    |
| Subsystem   | CPU Subsystem                    |    |
| Subsystem   | MCU Subsystem                    |    |
| Subsystem   | AON Subsystem                    |    |
| Subsystem   | Safety Island                    |    |
| Subsystem   | Security Subsystem               |    |
| Subsystem   | IO Subsystem                     |    |
| Subsystem   | Memory Subsystem                 |    |
| Subsystem   | AI Accelerator Subsystem         |    |
| Subsystem   | Debug Subsystem                  |    |
| Subsystem   | Sensor Subsystem                 |    |

---

# 五、我建议再把 Repo 里的对象分成 4 类

不是所有东西都应该以同样方式存在于 IP Repo。

| 类型          | 含义             | 示例                                    |
| ----------- | -------------- | ------------------------------------- |
| `IP`        | 固定功能、参数可配置     | UART、AES、Timer                        |
| `Generator` | 根据配置生成拓扑/RTL   | AXI Interconnect、CRG、Interrupt Router |
| `Wrapper`   | 隔离工艺或第三方实现     | SRAM/PLL/PHY Wrapper                  |
| `Subsystem` | 多个 IP 组成的可复用系统 | Safety Island、AON                     |

这一点很关键，例如：

```text
AXI Interconnect   → Generator
UART               → IP
SRAM Wrapper       → Wrapper
Safety Island      → Subsystem
```

不要全部都做成同一种 repository object。

---

# 六、优先级数量建议

如果把上述全部纳入规划，我建议规模大致控制为：

| Priority |  数量级 | 定位        |
| -------- | ---: | --------- |
| **P0**   |  ~70 | SoC 基础骨架  |
| **P1**   |  ~80 | 高频公共能力    |
| **P2**   | ~100 | 专业/复杂 IP  |
| **P3**   | ~80+ | 高端/前沿/产品域 |

也就是说，一个真正全域的 AIXSILICON IP Catalog 最终很容易达到 **300+ 个 logical IP entry**。

但这里千万不要理解成“自己实现 300 个 RTL IP”。

合理模式应该是：

**自研 + 开源纳管 + 第三方 Vendor IP Metadata + Wrapper + Generator + Reference Implementation**。

---

# 七、最值得优先自研的其实只有一部分

从 AIXSILICON 的定位来看，我会把自研重心放在：

**Fabric / Bridge / CDC / Interrupt / CRG / DMA / SRAM Controller / Safety Infrastructure / Security Infrastructure / SoC Integration Generator**

而像：

**PCIe / DDR PHY / USB PHY / SerDes / HBM / 高端 CPU / GPU**

更适合做：

```text
metadata
+ interface contract
+ wrapper
+ integration adapter
```

而不是自己重新实现。

这会让 IP Repo 从一开始就具备正确的工程边界：**它是 SoC 可复用资产目录，不等于“自研 RTL 目录”。**

如果下一步继续往工程化推进，我建议直接把这 300+ 项整理成一张 **IP Repo Master Catalog**，字段包括：

`IP_ID / Domain / Layer / Priority / IP/Generator/Wrapper/Subsystem / Interface / CBB Dependency / VIP Dependency / Generator / Open-source Candidate / Self-developed / SoC Studio Support`

这样基本就能直接变成 AIXSILICON `ip_repo/catalog.yaml` 的初版。


按照你现在这个定位，我会把 `ip-repo` 定义得非常明确：

> **IP-REPO = IP 源码与交付件主仓 + IP Catalog 管理仓 + FuseSoC 统一入口。**
> **方法论、开发规范、模板、流程编排全部不放这里，全部由 Skill 管理。**

也就是说，`ip-repo` 不是“IP 管理平台代码仓”，也不是“规范仓”，而是**真正发生 IP 开发、评审、验证、交付和版本管理的源码仓**。

这和我上一版说的 `docs/requirement.md / architecture.md` 并不冲突：这些不是“规范模板”，而是 **某一个具体 IP 的真实交付件**，因此应该留在 IP 源码仓里。

---

# 一、我推荐的顶层结构

我建议不要把目录搞得过于复杂，顶层控制在下面这些：

```text
ip-repo/
├── README.md
├── catalog/
│   ├── ip_catalog.yaml
│   ├── status.yaml
│   └── owners.yaml
│
├── ips/
│   ├── infrastructure/
│   ├── system/
│   ├── memory/
│   ├── peripheral/
│   ├── security/
│   ├── safety/
│   ├── debug/
│   ├── dft/
│   ├── compute/
│   ├── accelerator/
│   └── subsystem/
│
├── manifests/
│   ├── all.core
│   ├── p0.core
│   ├── p1.core
│   └── ...
│
├── examples/
│
└── tools/
    └── repo-local/
```

我会特别强调：

**不要在 repo 里再建：**

```text
methodology/
templates/
guidelines/
standards/
development_flow/
skill/
```

这些全部应该在：

```text
skill_repo
```

里维护。

---

# 二、最核心的是 `ips/`

真正的 IP 全部放：

```text
ips/
```

下面。

例如：

```text
ips/
├── infrastructure/
│   ├── axi/
│   │   ├── axi_interconnect/
│   │   ├── axi_crossbar/
│   │   ├── axi_register_slice/
│   │   └── axi_error_slave/
│   │
│   ├── apb/
│   │   ├── apb_interconnect/
│   │   └── apb_error_slave/
│   │
│   ├── bridge/
│   │   ├── axi2apb/
│   │   ├── axi2ahb/
│   │   └── ahb2apb/
│   │
│   └── cdc/
│       ├── axi_cdc_bridge/
│       └── apb_cdc_bridge/
│
├── system/
│   ├── crg/
│   ├── interrupt/
│   ├── dma/
│   ├── boot/
│   └── power/
│
├── memory/
├── peripheral/
├── safety/
├── security/
├── debug/
├── dft/
└── subsystem/
```

这里的层级不要太深。

我建议：

> **Domain → Subdomain → IP**

最多三级。

不要形成：

```text
ips/system/infrastructure/bus/amba/axi/bridge/...
```

这种过深目录。

---

# 三、单个 IP 的目录应该怎么组织

这部分最重要。

比如：

```text
ips/infrastructure/bridge/axi2apb/
```

我推荐：

```text
axi2apb/
├── README.md
├── metadata.yaml
├── axi2apb.core
│
├── docs/
│   ├── requirement.md
│   ├── architecture.md
│   ├── validation_plan.md
│   ├── user_guide.md
│   ├── register.md
│   └── rtm.md
│
├── rtl/
│   ├── axi2apb.sv
│   └── ...
│
├── dv/
│   ├── tb/
│   ├── tests/
│   ├── sequences/
│   └── assertions/
│
├── formal/
│
├── lint/
│
├── cdc/
│
├── constraints/
│
├── config/
│
├── scripts/
│
├── examples/
│
└── results/
    ├── lint/
    ├── simulation/
    ├── coverage/
    ├── formal/
    ├── cdc/
    ├── synthesis/
    └── ppa/
```

这就是一个完整 IP 的**工作目录**。

---

# 四、Skill 和 IP Repo 的关系应该这样定义

这是你现在架构里非常关键的一点。

不是：

```text
IP Repo
 ├── methodology
 ├── templates
 └── IP
```

而应该是：

```text
Skill Repo
   │
   │ 方法 / 模板 / Agent / Workflow
   │
   ▼
IP Repo
   │
   ├── requirement.md
   ├── architecture.md
   ├── RTL
   ├── DV
   ├── RTM
   ├── quality results
   └── release
```

也就是：

> **Skill 定义“怎么开发”。**
> **IP Repo 保存“开发了什么”。**

这个边界非常干净。

例如：

```text
IP Development Skill
        │
        ├─ 生成 requirement.md
        ├─ 生成 architecture.md
        ├─ 生成 RTL
        ├─ 构建 DV
        ├─ 跑 lint / sim / formal
        └─ 生成 RTM
                 │
                 ▼
        ips/.../axi2apb/
```

所以 Skill 本身完全不需要进入 `ip-repo`。

---

# 五、`metadata.yaml` 应该成为单个 IP 的核心管理入口

我建议每个 IP 必须有：

```text
metadata.yaml
```

这是 IP Repo 的核心。

例如：

```yaml
ip:
  name: axi2apb
  display_name: AXI to APB Bridge
  id: aixsilicon:ip:axi2apb

  domain: infrastructure
  subdomain: bridge

  type: ip
  priority: P0

  status: development
  maturity: alpha

  version: 0.3.0

  owner: platform
  maintainer: xxx

interfaces:
  - protocol: axi4
    role: slave

  - protocol: apb4
    role: master

features:
  burst: true
  wrap_burst: true
  cdc: true
  timeout: true
  width_conversion: true

dependencies:
  cbb:
    - sync_fifo
    - async_fifo

  vip:
    - axi4
    - apb4

fusesoc:
  core: axi2apb.core

quality:
  lint: pass
  simulation: pass
  coverage: pass
  formal: partial
  cdc: pass
  synthesis: pass

release:
  current: 0.3.0
  baseline: false
```

SoC Studio、Skill、CI、Catalog 页面都只需要解析它。

---

# 六、FuseSoC 应该作为“依赖和构建入口”

既然你已经明确：

> ip-repo 中所有 IP 都可以通过 FuseSoC 引用

那我非常赞成每个 IP 自己维护：

```text
<ip>.core
```

例如：

```text
axi2apb.core
```

里面定义：

```yaml
CAPI=2:

name: aixsilicon:ip:axi2apb:0.3.0

filesets:
  rtl:
    files:
      - rtl/axi2apb_pkg.sv
      - rtl/axi2apb.sv
    file_type: systemVerilogSource

  tb:
    files:
      - dv/tb/axi2apb_tb.sv
    file_type: systemVerilogSource

targets:
  default:
    filesets:
      - rtl

  sim:
    filesets:
      - rtl
      - tb
```

Dependencies 可以直接引用：

```yaml
depend:
  - aixsilicon:cbb:async_fifo
```

这样自然形成：

```text
ip_repo
   ↓
cbb_repo

ip_repo
   ↓
hwif_repo

dv
   ↓
vip_repo
```

这比在 repo 自己实现一套 dependency system 要好得多。

---

# 七、Catalog 不要和每个 IP metadata 重复维护

这一点我建议特别注意。

不要让：

```text
catalog/ip_catalog.yaml
```

重新人工填写一遍每个 IP 的信息。

正确方式应该是：

```text
ips/**/metadata.yaml
          │
          ▼
       扫描/聚合
          │
          ▼
catalog/ip_catalog.yaml
```

也就是说：

### SSOT

真正的 SSOT 是：

```text
ips/<...>/<ip>/metadata.yaml
```

### Catalog

`catalog/ip_catalog.yaml` 是机器生成的索引。

例如：

```yaml
generated_at: 2026-09-06

ips:
  - name: axi2apb
    path: ips/infrastructure/bridge/axi2apb
    priority: P0
    status: development
    version: 0.3.0

  - name: apb_interconnect
    path: ips/infrastructure/apb/apb_interconnect
    priority: P0
    status: planning
```

这样绝对不要出现两份 SSOT。

---

# 八、状态体系建议统一

因为你说：

> ip-repo 只维护 IP 列表、状态等。

那状态设计要非常清楚。

我推荐两套字段分开：

## Development Status

```text
planning
requirement
architecture
implementation
verification
qualification
released
deprecated
```

反映**开发走到哪一步**。

---

## Maturity

```text
experimental
alpha
beta
production
legacy
```

反映**这个 IP 能不能放心用**。

例如：

```yaml
status: verification
maturity: alpha
```

和：

```yaml
status: released
maturity: production
```

含义完全不同。

---

# 九、Quality 不应该只写 PASS/FAIL

建议 metadata 只维护摘要：

```yaml
quality:
  lint:
    status: pass

  simulation:
    status: pass

  coverage:
    status: pass
    line: 98.2
    toggle: 95.7
    functional: 96.4

  formal:
    status: partial

  cdc:
    status: pass

  synthesis:
    status: pass
```

详细报告放：

```text
results/
```

例如：

```text
results/
├── lint/
├── simulation/
├── coverage/
├── formal/
├── cdc/
└── synthesis/
```

这样 metadata 是 Dashboard，results 是证据。

---

# 十、results 是否应该提交 Git？

这里我建议做区分。

## 应该进 Git

小体积、关键结论：

```text
summary.md
summary.json
coverage_summary.json
lint_summary.json
ppa_summary.yaml
```

## 不建议进 Git

大量：

```text
VCS logs
waveform
FSDB
VPD
full synthesis DB
STA intermediate
coverage DB
```

这些应该：

```text
artifact server
CI artifacts
NAS / object storage
```

metadata 只保存：

```yaml
artifacts:
  simulation:
    uri: ...
```

否则几年之后 Git repo 会膨胀到不可维护。

---

# 十一、我更建议把 deliverables 独立出来

考虑你强调：

> Skill 完成的所有交付件都放这里。

那么单 IP 下，我甚至更推荐一个更统一的结构：

```text
axi2apb/
├── metadata.yaml
├── axi2apb.core
├── README.md
│
├── docs/
├── design/
├── verification/
├── implementation/
├── quality/
└── examples/
```

对应：

```text
docs/
├── requirement.md
├── architecture.md
├── validation_plan.md
├── rtm.md
└── user_guide.md
```

```text
design/
├── rtl/
├── config/
└── constraints/
```

```text
verification/
├── tb/
├── tests/
├── assertions/
└── formal/
```

```text
quality/
├── lint/
├── cdc/
├── rdc/
├── coverage/
└── synthesis/
```

但是这有一个问题：

FuseSoC 和 EDA 工程一般习惯：

```text
rtl/
dv/
formal/
```

因此从实际工程便利性来说，我反而更推荐**扁平版本**：

```text
axi2apb/
├── docs/
├── rtl/
├── dv/
├── formal/
├── constraints/
├── config/
├── scripts/
├── results/
├── metadata.yaml
└── axi2apb.core
```

**少一层目录，开发人员更舒服。**

---

# 十二、Generator IP 怎么放

例如 AXI Interconnect Generator。

我建议：

```text
ips/infrastructure/axi/axi_interconnect/
├── metadata.yaml
├── axi_interconnect.core
├── README.md
│
├── docs/
├── generator/
│   ├── src/
│   ├── schema/
│   └── templates/
│
├── rtl/
├── dv/
├── examples/
└── results/
```

这里的：

```text
generator/
```

是 **这个 IP 产品本身的 generator source**。

它不是 Skill。

区别：

### Skill

```text
怎么开发 AXI Interconnect
怎么生成 requirement
怎么做 architecture
怎么做 verification
```

### Generator

```text
输入 4M × 8S 配置
生成对应 AXI Interconnect RTL
```

所以 Generator 当然属于 IP Repo。

---

# 十三、Subsystem 也建议放在同一个 Repo

如果你的定义是：

> IP Repo 是所有可复用设计资产源码仓

那我不建议单独建立 subsystem repo。

直接：

```text
ips/subsystem/
├── aon_subsystem/
├── safety_island/
├── security_subsystem/
├── cpu_subsystem/
└── memory_subsystem/
```

其 `.core` 依赖：

```yaml
depend:
  - aixsilicon:ip:timer
  - aixsilicon:ip:watchdog
  - aixsilicon:ip:apb_interconnect
  - aixsilicon:ip:reset_controller
```

这正好发挥 FuseSoC 最大价值。

---

# 十四、推荐最终版

如果让我现在冻结 AIXSILICON `ip-repo`，我会采用这个：

```text
ip-repo/
│
├── README.md
│
├── catalog/
│   ├── catalog.yaml              # 自动生成
│   ├── priorities.yaml           # P0/P1/P2/P3 视图
│   └── releases.yaml
│
├── ips/
│   ├── infrastructure/
│   │   ├── axi/
│   │   ├── apb/
│   │   ├── ahb/
│   │   ├── bridge/
│   │   ├── cdc/
│   │   └── noc/
│   │
│   ├── system/
│   │   ├── clock_reset/
│   │   ├── interrupt/
│   │   ├── dma/
│   │   ├── power/
│   │   └── boot/
│   │
│   ├── memory/
│   ├── peripheral/
│   ├── debug_trace/
│   ├── safety/
│   ├── security/
│   ├── dft/
│   ├── chip/
│   ├── compute/
│   ├── accelerator/
│   └── subsystem/
│
├── examples/
│   ├── minimal_soc/
│   ├── mcu_soc/
│   └── safety_soc/
│
└── tools/
    └── repo/
        ├── generate_catalog.py
        ├── validate_metadata.py
        └── check_fusesoc.py
```

单 IP：

```text
ips/infrastructure/bridge/axi2apb/
│
├── metadata.yaml
├── axi2apb.core
├── README.md
│
├── docs/
│   ├── requirement.md
│   ├── architecture.md
│   ├── validation_plan.md
│   ├── rtm.md
│   └── user_guide.md
│
├── rtl/
├── dv/
├── formal/
├── constraints/
├── config/
├── generator/        # 仅 Generator 类 IP 存在
├── scripts/
├── examples/
└── results/
```

我认为这个边界最符合你现在的体系：

```text
skill_repo
    ↓
定义方法、规范、Agent、Workflow
    ↓
开发
    ↓
ip_repo
    ↓
真实源码 + 文档交付件 + DV + Quality + Metadata
    ↓
FuseSoC
    ↓
SoC Studio / Project
```

其中真正需要长期冻结的只有三个接口：

**`metadata.yaml` schema、FuseSoC VLNV 命名规则、单 IP 基础目录约定。**

其他诸如 requirement 怎么写、architecture 怎么写、验证做到什么程度，都应该由 Skill 演进，而不要硬编码在 IP Repo 的仓库规则里。这样以后 Skill 升级不会反过来逼着你重构整个 IP Repo。
