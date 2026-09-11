# Watchdog：寄存器及复用生成边界

原生PeakRDL CSR/package和external适配器由RDL确定性生成，禁止手改generated。
正式适配选择apb4-flat，已在build/g2_csr_candidate生成15位地址/32位数据原生接口。
旧passthrough+APB包装保留为待替换候选。新adapter传完整APB信号，原生请求只做
协议应答，业务副作用仍由顶层成功完成边沿门控，详见03_bus_datapath.md。
生成包/module/adapter必须同时更新并编译，不能混用两种CPU接口的产物。

generated寄存器路径由RTL顶层映射中97个LLD_REG行为消费；实际RDL字段全覆盖由
结构枚举检查证明，地址/位宽由RDL工具生成。软件Header、IP-XACT、UVM RAL、HTML
及CSR manifest必须绑定同一源与工具版本，编译顺序package先于module。

CBB round_robin_arbiter 0.1.0仅NUM_REQ=2、PC_IMPL=0；core缺paramtype的兼容问题
在G3真实构建前处理并留证。不复制CBB源，临时元数据不能视为资产已修复。
