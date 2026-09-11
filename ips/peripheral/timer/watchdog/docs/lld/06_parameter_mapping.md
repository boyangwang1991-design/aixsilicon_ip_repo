# Watchdog：PC 参数到微架构映射

- `NUM_CHANNELS`：实例化通道、staging/镜像/锁/输出数组，1..16；不增加每通道计时间隔。
- `COUNTER_WIDTH`：主/影子C与Deadline位宽32/48/64，配置容器高位提交拒绝，诊断读零扩展。
- `PRESCALE_WIDTH`：主/影子D位宽1..16，P+1周期tick，禁止截断非法P。
- `NUM_CLIENTS`：每通道并行客户端1..32；软件配置容器32槽，仅已实现且被选择项参与。
- `SOURCE_WIDTH`：可信身份有效宽度1..16，内部16位零扩展，选中OWNER_SOURCE超宽拒绝。
- `SYNC_STAGES`：两域同步和warm取消对齐深度2..4，所有时延公式统一S。
- `SUPPORT_TOKEN_QA`：TOKEN/QA资格与token更新可用性；关闭时模式提交UNSUPPORTED且token镜像0。
- `SUPPORT_SUPERVISION`：GROUP/ALIVE/FLOW可用性；关闭只能SINGLE，不静默降级非法配置。
- `SUPPORT_HW_EVENT`：硬件事件请求/握手路径；关闭ready=0，硬件服务配置提交UNSUPPORTED。
- `SAFETY_EN`：独立保护路径存在性及策略强制位；关闭仍检测非法FSM编码。
- `ALLOW_RUNTIME_UPDATE`：仅RUN、无锁/无pending时允许四类时间字段更新；关闭时RUN提交拒绝。
- `DIAG_INJECT_EN`：生产裁剪注入入口；不改变IRQ_TEST与一般诊断读取。
- `AUTO_START_MASK`：每通道POR首边沿自动启动，无pclk依赖；未选通道DISABLED。
- `NO_STOP_MASK`：每通道软件STOP禁用策略，与ENABLE_LOCK共同决定。
- `HARD_CFG_LOCK_MASK`：每通道CFG_LOCK的POR初值，只能POR重建，不能软件清除。
- `DEFAULT_CFG`：每通道命名完整配置映射config_t；默认数组按通道数复制，显式配置长度须一致。

## DEFAULT_CFG 到实现容器

命名属性在实例适配时打包到config_t的16个主配置字及32×7客户端字；字段结构及
软件映射仍由RDL提供。CLIENT_DEFAULT展开到每个实现客户端，再以唯一client索引
的CLIENT_OVERRIDES整项替换；未实现槽清0。不先截断再校验，所有显式参数先过PC。
实际SV参数传播到每个channel，并分别取三个通道mask的该位；通道索引不是新参数旋钮。

实例合法性必须在生成/编译阶段拒绝非法NUM/width/mask和默认配置；不能用运行时
悄悄关通道替代。支持矩阵中negative Schema仅证明输入拒绝，合法配置仍须PV真实构建。
普通SV参数化无需拓扑生成器；寄存器仍完整执行SystemRDL生成与一致性核对。
