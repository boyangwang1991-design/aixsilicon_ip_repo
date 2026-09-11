# Watchdog：分解与实现组织

六个 L1 责任均一对一映射到 LLD module。逻辑责任与物理 RTL module 不强制相同：
INTEGRATION、BUS、TRANSPORT、DISPATCH 可作为 watchdog_top 的有名逻辑区；CHANNEL
为每通道 watchdog_channel；SAFETY 在通道内保持独立寄存/比较区域，邮箱保护留在 top。
此选择保留既有集成接口并避免无意义的巨宽端口重布线；物理独立性由独立状态锥和
综合/布局约束保证，不能由文件数量自证。寄存器译码使用原生 PeakRDL CSR 与生成适配器。

共享类型/常量属于 watchdog_pkg；command_t 负载含可信身份与权限，config_t 包含完整
通道及全部客户端配置，snapshot_t 包含一致更新后状态。每次仅一个状态修改命令，
计时、期限和安全检查并行执行且不可被总线/仲裁阻塞。

主要数据流：APB 完成 → 捕获稳定邮箱 → 请求同步 → 两源仲裁 → 通道计算下一状态 →
锁存完成/快照 → 应答同步 → APB 发布 DONE/镜像。运行配置只在指定原子边界生效。

NA：无 SRAM/MBIST、DMA、乱序多 ID 或独立拓扑生成器；参数化 SystemVerilog 与
SystemRDL 生成分支仍必需。六个模块各自的实际对象分册见 index.md。
