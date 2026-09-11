# LRS 结构与来源核对

当前结果：结构抽取成功；G0 已按用户 “approve, continue” 批准并冻结。

注意：当前 quality evaluator 对 draft/open/未冻结 LRS 仍输出 G0 pass，其检查仅为文档和模型结构。
这是前轮已复现的门禁实现缺口，历史证据保留在 g0_approved/prior_g0_discrepancy.json；当前 G0 依据真实用户批准，G1 仍不得只凭机器 pass 冻结。

- 原契约带编号需求：110 条；LRS 原子句及补充条款：169 条。
- 未映射原始 ID：[]；非来源 ID：[]。
- 重复 ID：0；正文/验收/验证方法缺失均见机器审计 JSON。
- 分册均采用平铺目录，单分册最多 10 个需求 META；分拆后 ID 不依赖文件位置。
- GEN/LP 提示由 90_applicability_na.md 逐项解释；参数验证不因 GEN 不适用而省略。
- 本次审核是作者的结构与来源检查，不能代替独立需求评审或协议核验。
- 验收条件保留具体来源行为及对应比较场景；复杂复合条目的进一步语义原子性仍需独立评审。
- 来源表格中的物理寄存器位表未重复维护，ABI 需求明确引用契约 §7，后续 02 owner 必须逐字段核对。

证据：lrs_source_audit.json、preflight_checks.json 与 build/preflight/lrs_extract.txt。
