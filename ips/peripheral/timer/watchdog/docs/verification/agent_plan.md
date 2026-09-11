# UVM Agent与环境计划

采用UVM 1.2；环境为`watchdog_env`，组件有APB requester agent、WDT事件agent、时钟复位agent、输出monitor、RM、scoreboard、coverage subscriber和virtual sequencer。
协议agent指验证组件，不涉及AI子代理。

## 复用资产

APB使用`aixsilicon:vip:apb:1.0.0`的apb_pkg/apb_master_agent/apb_item，并独立实例化apb_monitor，source由VIP仓只读提供，FuseSoC依赖管理，不复制进IP。
该资产当前developing/M1、G6未运行；不能把它标为qualified。项目内先运行协议资格用例并绑定源哈希：
APB4完整SETUP/ACCESS、zero/wait响应、背靠背、读写PPROT/PSTRB、PSLVERR、reset中断、稳定负载与超时。
资格失败先保留证据；不得静默关掉checker绕过，必要修正按VIP owner边界记录。

watchdog PADDR为15位，VIP物理地址32位时由TB取低15位并断言高17位零；负向越界在DUT实际15位空间内生成。
VIP runtime配置APB4、data_width32、enable_strb/prot=1、wakeup/RME/user=0、requester active、checker/coverage开启。
`src_id`及cfg/service/diag/test可信授权由专用TB侧带驱动，与APB transaction一同保持到接受，monitor统一捕获。
PSLVERR是合法错误响应，不应被视为协议违规；只有专门协议负向资格测试启用violation能力。

## 其他组件

- 硬件事件agent：wdt_clk同域、valid保持至ready，负载含channel/client/source/event/data；禁止裸异步脉冲。
- 时钟复位agent：相位可控的独立pclk/wdt_clk，POR异步断言，preset独立；warm为单WDT周期可信事件。
- 恢复agent：done保持直到ack，再撤销；支持故意陈旧done和最终期限碰撞。
- 输出monitor：WDT域和pclk域分别采样，不将IRQ同步延迟套用于安全请求。
- 注入driver：仅通过LLD受控诊断入口或声明的验证bind故障点，不新增DUT功能后门。

APB monitor analysis_port同时送RM/RAL predictor/coverage；WDT和输出monitor送RM/scoreboard，virtual sequencer仅协调刺激。
所有关键输出均由checker_plan中的独立期望检查，coverage不能代替scoreboard。
