# GPIO

参数化APB4 GPIO，输入合同为 [gpio_contract.md](gpio_contract.md)。
已执行完整 testcase 回归、模块单测、覆盖率分析、RTM、文档和三点 PPA 表征，按用户授权进行条件候选交付。G3 为 PASS WITH CONDITION；CDC/RDC、Formal、覆盖率和参数空间等未关闭技术项见执行状态，不宣称无条件发布签核。

- [需求](docs/lrs/index.md)
- [架构](docs/hld/index.md)
- [微设计](docs/lld/index.md)
- [验证计划](docs/verification/index.md)
- [执行状态](reports/quality/full_process.md)

原始执行证据、PeakRDL/覆盖率 HTML、工具日志和编译产物仅供本地使用，禁止上传
GitHub。新输出写入被忽略的 `build/`；旧 `reports/evidence/` 缓存也不随 Git 交付。
以上执行状态为历史摘要，新 clone 须按验证计划和 `scripts/`、FuseSoC target 重跑相关
阶段并刷新报告后重新验收。旧 GPIO 0.1.0 candidate 包及发布记录仅本地保留。
