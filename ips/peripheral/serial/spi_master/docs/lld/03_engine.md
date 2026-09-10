# ENGINE 微架构

状态编码 IDLE=0, FETCH=1, RESOURCE=2, NEW_IDLE=3, SETUP=4, SHIFT=5, GAP=6, HOLD_CS=7, HOLD_TIME=8, IDLE_TIME=9。
每个活动 descriptor 缓存 cfg/len/tag；配置仅 disabled 可改，可直接选择稳定的 CS 配置。
RESOURCE 在首次资源完整时原子取 TX 并预留 RX；CS 尚未激活时先更新 CPOL、等待新 idle、断言 CS、执行 setup。
从 CS 断言沿到第一 leading 沿精确 SETUP+1。每次边沿用倒数器，重装 CLKDIV，零代表下一沿执行。
SHIFT 的 edge_idx 从 0 到 2*FRAME_BITS-1，偶数 leading、奇数 trailing。
CPHA0 在准备帧时建立首位，leading 采样，非末 trailing 推出下一位；CPHA1 leading 推位，trailing 采样。
接收寄存器按数值 bit index 放置采样，帧开始清零；末 trailing 提交含当沿采样的完整结果。
仅一个活动 RX 预留槽；开始下一帧时容量判断包含本沿要提交的当前帧，但不乐观依赖同沿 APB pop。
下一帧 TX 使用组合 FIFO 头及边沿前 occupancy，末 trailing 原子取下一 entry，并同步建立 CPHA0 首位。
可用资源在前一周期已就绪时无需额外预取存储；H=1 时亦连续。FRAME_GAP 加在 H 上，DUMMY 不加 gap。
资源不足仅帧边界停顿，ALLOW_STALL=0 同沿记录资源错误；ALLOW_STALL=1 进入 RESOURCE。
DUMMY 将 frame bits 等效为 1，MOSI 常值，不碰数据 FIFO；progress 按完整周期计数。
KEEP_CS 段末 trailing 提交 RX 并完成段；否则装载 HOLD，释放 CS 时完成段/事务，然后等待旧 IDLE。
HOLD_CS 无命令时 WAIT_CMD；取到错误 CS 的 descriptor 后安全终止。RELEASE 无 CS 时只完成段。
无进展等待计数饱和，原因改变不重置；资源进展优先于同沿阈值，setup/shift/gap/hold/idle 不计时。
ABORT 在完成沿前组合加入 stop 条件，禁止同沿开始新帧/命令，完整当前帧后按 hold/idle 收尾。
ABORT 在非 SHIFT 状态不等资源；已在 HOLD/IDLE 倒计时不得重新开始，保证终止上界。
终止清 TX/CMD、保留完整 RX，置 fault；软件 ABORT 额外置 ABORT_DONE。正常完成被 stop 抑制。
busy 为状态非 IDLE、命令非空或 aborting；活动 valid 与 CS active 独立。非法状态安全进入终止路径。

<!-- LLD_MODULE_META
id: LLD.MOD.SPI_MASTER.ENGINE
name: ENGINE
hld_ref:
- HLD.MOD.SPI_MASTER.ENGINE
responsibility: 片选/段/帧执行、时序调度、资源预留、超时、安全终止
END_LLD_MODULE_META -->
<!-- LLD_DATAPATH_META
id: LLD.DP.SPI_MASTER.ENGINE
module_ref: LLD.MOD.SPI_MASTER.ENGINE
width: 32
latency: APB zero wait; SPI counted edges
description: '状态编码 IDLE=0, FETCH=1, RESOURCE=2, NEW_IDLE=3, SETUP=4, SHIFT=5, GAP=6, HOLD_CS=7, HOLD_TIME=8,
  IDLE_TIME=9。

  每个活动 descriptor 缓存 cfg/len/tag；配置仅 disabled 可改，可直接选择稳定的 CS 配置。

  RESOURCE 在首次资源完整时原子取 TX 并预留 RX；CS 尚未激活时先更新 CPOL、等待新 idle、断言 CS、执行 setup。

  从 CS 断言沿到第一 leading 沿精确 SETUP+1。每次边沿用倒数器，重装 CLKDIV，零代表下一沿执行。

  SHIFT 的 edge_idx 从 0 到 2*FRAME_BITS-1，偶数 leading、奇数 trailing。

  CPHA0 在准备帧时建立首位，leading 采样，非末 trailing 推出下一位；CPHA1 leading 推位，trailing 采样。

  接收寄存器按数值 bit index 放置采样，帧开始清零；末 trailing 提交含当沿采样的完整结果。

  仅一个活动 RX 预留槽；开始下一帧时容量判断包含本沿要提交的当前帧，但不乐观依赖同沿 APB pop。

  下一帧 TX 使用组合 FIFO 头及边沿前 occupancy，末 trailing 原子取下一 entry，并同步建立 CPHA0 首位。

  可用资源在前一周期已就绪时无需额外预取存储；H=1 时亦连续。FRAME_GAP 加在 H 上，DUMMY 不加 gap。

  资源不足仅帧边界停顿，ALLOW_STALL=0 同沿记录资源错误；ALLOW_STALL=1 进入 RESOURCE。

  DUMMY 将 frame bits 等效为 1，MOSI 常值，不碰数据 FIFO；progress 按完整周期计数。

  KEEP_CS 段末 trailing 提交 RX 并完成段；否则装载 HOLD，释放 CS 时完成段/事务，然后等待旧 IDLE。

  HOLD_CS 无命令时 WAIT_CMD；取到错误 CS 的 descriptor 后安全终止。RELEASE 无 CS 时只完成段。

  无进展等待计数饱和，原因改变不重置；资源进展优先于同沿阈值，setup/shift/gap/hold/idle 不计时。

  ABORT 在完成沿前组合加入 stop 条件，禁止同沿开始新帧/命令，完整当前帧后按 hold/idle 收尾。

  ABORT 在非 SHIFT 状态不等资源；已在 HOLD/IDLE 倒计时不得重新开始，保证终止上界。

  终止清 TX/CMD、保留完整 RX，置 fault；软件 ABORT 额外置 ABORT_DONE。正常完成被 stop 抑制。

  busy 为状态非 IDLE、命令非空或 aborting；活动 valid 与 CS active 独立。非法状态安全进入终止路径。

  '
END_LLD_DATAPATH_META -->
<!-- LLD_FSM_META
id: LLD.FSM.SPI_MASTER.ENGINE
module_ref: LLD.MOD.SPI_MASTER.ENGINE
reset_state: IDLE
encoding: explicit binary
states:
- IDLE
- FETCH
- RESOURCE
- NEW_IDLE
- SETUP
- SHIFT
- HOLD_CS
- HOLD_TIME
- IDLE_TIME
illegal_state_handling: safe stop; release CS, fault
transitions: '状态编码 IDLE=0, FETCH=1, RESOURCE=2, NEW_IDLE=3, SETUP=4, SHIFT=5, GAP=6, HOLD_CS=7, HOLD_TIME=8,
  IDLE_TIME=9。

  每个活动 descriptor 缓存 cfg/len/tag；配置仅 disabled 可改，可直接选择稳定的 CS 配置。

  RESOURCE 在首次资源完整时原子取 TX 并预留 RX；CS 尚未激活时先更新 CPOL、等待新 idle、断言 CS、执行 setup。

  从 CS 断言沿到第一 leading 沿精确 SETUP+1。每次边沿用倒数器，重装 CLKDIV，零代表下一沿执行。

  SHIFT 的 edge_idx 从 0 到 2*FRAME_BITS-1，偶数 leading、奇数 trailing。

  CPHA0 在准备帧时建立首位，leading 采样，非末 trailing 推出下一位；CPHA1 leading 推位，trailing 采样。

  接收寄存器按数值 bit index 放置采样，帧开始清零；末 trailing 提交含当沿采样的完整结果。

  仅一个活动 RX 预留槽；开始下一帧时容量判断包含本沿要提交的当前帧，但不乐观依赖同沿 APB pop。

  下一帧 TX 使用组合 FIFO 头及边沿前 occupancy，末 trailing 原子取下一 entry，并同步建立 CPHA0 首位。

  可用资源在前一周期已就绪时无需额外预取存储；H=1 时亦连续。FRAME_GAP 加在 H 上，DUMMY 不加 gap。

  资源不足仅帧边界停顿，ALLOW_STALL=0 同沿记录资源错误；ALLOW_STALL=1 进入 RESOURCE。

  DUMMY 将 frame bits 等效为 1，MOSI 常值，不碰数据 FIFO；progress 按完整周期计数。

  KEEP_CS 段末 trailing 提交 RX 并完成段；否则装载 HOLD，释放 CS 时完成段/事务，然后等待旧 IDLE。

  HOLD_CS 无命令时 WAIT_CMD；取到错误 CS 的 descriptor 后安全终止。RELEASE 无 CS 时只完成段。

  无进展等待计数饱和，原因改变不重置；资源进展优先于同沿阈值，setup/shift/gap/hold/idle 不计时。

  ABORT 在完成沿前组合加入 stop 条件，禁止同沿开始新帧/命令，完整当前帧后按 hold/idle 收尾。

  ABORT 在非 SHIFT 状态不等资源；已在 HOLD/IDLE 倒计时不得重新开始，保证终止上界。

  终止清 TX/CMD、保留完整 RX，置 fault；软件 ABORT 额外置 ABORT_DONE。正常完成被 stop 抑制。

  busy 为状态非 IDLE、命令非空或 aborting；活动 valid 与 CS active 独立。非法状态安全进入终止路径。

  '
END_LLD_FSM_META -->
<!-- LLD_RESET_META
id: LLD.RST.SPI_MASTER.ENGINE
reset_domain: preset_n
type: asynchronous assert, synchronous release by integration
module_ref: LLD.MOD.SPI_MASTER.ENGINE
reset_values: contract REC-007; FIFO RAM untouched
END_LLD_RESET_META -->

组合辅助操作使用 void function，确保 always_comb 包含函数体读取的全部信号。
