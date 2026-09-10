# Reference model 与 checker

独立 oracle 将软件事务展开为线性 MOSI/MISO 位队列，通过外部引脚的 CPOL/CPHA 事件逐位比较。它不读取 DUT 移位寄存器，也不复制其 FSM。每帧 RX 与独立零扩展 expected word 比较。

时序检查比较 PCLK 计数：首沿 SETUP+1；半周期 DIV+1；帧间附加 FRAME_GAP；最后沿到 CS 释放 HOLD+1。CSR 检查每次 ACCESS 的 ready/error、读值和副作用。engine UT 用直接接口精确注入超时临界、等待原因切换、末沿中止和计数回绕。

APB master、可配置 slave、oracle 和 checker 在 verification/th/spi_tb_if.sv，UVM env 管理虚接口及测试生命周期。测试直接调用 BFM task；不伪造尚未实现的标准 VIP/sequence 架构。RAL 从 RDL 生成；实际动态测试使用显式 CSR oracle，不以 RAL 自预测替代 correctness check。
