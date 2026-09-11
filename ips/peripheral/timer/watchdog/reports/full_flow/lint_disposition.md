# SpyGlass 警告处置（仍未签核）

当前全功能FuseSoC lint：0 Fatal、0 Error、2412 Warning、16 Info；后端返回11，因此构建退出失败。原始证据为g3_fusesoc_lint_safety.log，不将进程失败改写为PASS。

| 规则 | 观察与处置 |
|---|---|
| W415a | 858条，主要为PeakRDL展开寄存器decode/read mux的默认赋值后条件覆盖，以及q/n明确优先级赋值；保留生成器源，不手改生成RTL。待逐项绑定实例与互斥/优先级依据形成限范围waiver。 |
| W528 | 1542条Warning与1条Info，主要为external CSR的wr_data/biten未由包装层消费；实际副作用使用APB完成且无PSLVERR的原始事务，RDL仅提供访问属性/掩码/握手。新加入的seen_set未使用已删除，须新一轮lint验证。 |
| W240 | 3条Warning与1条Info：CBB组合模式忽略grant_ack；PeakRDL APB4模块内部未读PENABLE/PPROT，顶层已使用完整APB完成条件与可信权限侧带。待限定路径豁免并以APB资格/回归佐证。 |
| STARC05-2.2.3.3 | 2条busy/exec_done重复NBA；完成与新接收受busy_error互斥。待明确编码或带条件证明豁免。 |
| STARC05-1.3.1.3 | 3条复位作同步门控；POR同步释放驱动本地域使能、APB功能复位不清POR保留状态。必须结合CDC/RDC检查逐路径处理，不能仅依据功能仿真关闭。 |
| SYNTH_5064 | 4条来自只读CBB断言被综合忽略，非DUT功能逻辑；断言在仿真保持启用。 |
| CMD_param03等 | 参数声明/设计信息，不是错误；保存原报告。 |

现有原报告没有意外锁存/组合环的违规项，但G3仍需最终综合、更新后lint及CDC/RDC证据。上述只是处置分析，尚不是全局忽略规则或签核通过。
