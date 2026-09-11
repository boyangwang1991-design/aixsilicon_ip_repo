# GPIO 微设计：文档控制

<!-- LLD_DOC_META
schema_version: '2.0'
ip_name: gpio
delivery_model: parameterized
lrs_baseline: GPIO-CONTRACT-59597f3b2da6
hld_baseline: GPIO-HLD-001
document_version: 1.0.0-draft
status: approved
microarchitecture_baseline: GPIO-LLD-001
END_LLD_DOC_META -->

本阶段输入为已批准HLD、LRS及参数合同。用户授权原文为 `approve, complete the rest`。
本次执行者可在校验通过后记录后续设计技术审批；测试/覆盖率/物理门禁仍只依据真实证据。
所有周期指正沿间隔，沿t计算使用沿t之前的寄存状态；写事务只在合法Access完成沿提交。
RDL负责字段结构，本目录负责状态更新、并发优先级、复位和实现映射。
