# CSR 微架构

使用 PeakRDL passthrough CPU 接口，由组合 APB 包装器只在 ACCESS 送请求，避免标准 APB exporter 的流水等待。
地址常量和访问属性由 RDL 节点生成，包装器仅执行运行期错误/字节合并合法性检查，不保存第二套 CSR。
全部失败写和零 strobe 写均禁止 CSR 请求与命令/FIFO 副作用；读错误返回零。
普通 RW 的 byte merge 后判断合法性；CTRL 同值写允许，变化受 busy/fault 限制。
WO 副作用用请求译码 + 当前 pwdata，不能以延迟一个周期的 CSR 存储值提交。
W1C 每个事件/错误位独立 hwset，新事件优先。软复位清全部 CSR 与执行状态。
每个 CS 的寄存器物化为八个槽；NUM_CS 限制 wrapper 访问且未用配置不会到达执行引脚。

<!-- LLD_MODULE_META
id: LLD.MOD.SPI_MASTER.CSR
name: CSR
hld_ref:
- HLD.MOD.SPI_MASTER.CSR
responsibility: APB 零等待访问检查、SystemRDL 配置/状态/中断、命令原子提交
END_LLD_MODULE_META -->
<!-- LLD_DATAPATH_META
id: LLD.DP.SPI_MASTER.CSR
module_ref: LLD.MOD.SPI_MASTER.CSR
width: 32
latency: APB zero wait; SPI counted edges
description: '使用 PeakRDL passthrough CPU 接口，由组合 APB 包装器只在 ACCESS 送请求，避免标准 APB exporter 的流水等待。

  地址常量和访问属性由 RDL 节点生成，包装器仅执行运行期错误/字节合并合法性检查，不保存第二套 CSR。

  全部失败写和零 strobe 写均禁止 CSR 请求与命令/FIFO 副作用；读错误返回零。

  普通 RW 的 byte merge 后判断合法性；CTRL 同值写允许，变化受 busy/fault 限制。

  WO 副作用用请求译码 + 当前 pwdata，不能以延迟一个周期的 CSR 存储值提交。

  W1C 每个事件/错误位独立 hwset，新事件优先。软复位清全部 CSR 与执行状态。

  每个 CS 的寄存器物化为八个槽；NUM_CS 限制 wrapper 访问且未用配置不会到达执行引脚。

  '
END_LLD_DATAPATH_META -->
<!-- LLD_RESET_META
id: LLD.RST.SPI_MASTER.CSR
reset_domain: preset_n
type: asynchronous assert, synchronous release by integration
module_ref: LLD.MOD.SPI_MASTER.CSR
reset_values: contract REC-007; FIFO RAM untouched
END_LLD_RESET_META -->
