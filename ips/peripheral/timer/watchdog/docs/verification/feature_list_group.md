# 多客户端组监督：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.GROUP
name: 多客户端组监督
description: 多客户端组监督的可执行正确性证明
priority: must
req_ref:
- LRS.FUNC.WATCHDOG.SUP.001
- LRS.FUNC.WATCHDOG.SUP.002
- LRS.FUNC.WATCHDOG.SUP.003
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

不同source/client报到；未要求客户端、早到、重复、最后必需客户端；多个通道不同timeout并发。

独立判据：集合oracle仅接受当前轮合法成员；最后成员才刷新；重复不换token；超时missing=REQUIRE_MASK减已见集合；其他通道独立计时。

风险与边界：客户端首/末×重复×窗口；require稀疏/全置位。

### LRS.FUNC.WATCHDOG.SUP.001

客户端 ID 只是选择索引，身份保护由 OWNER_SOURCE 与可信来源比较实现。同一个 OWNER_SOURCE 管理多个客户端时，不宣称这些任务彼此隔离。

验收：匹配 OWNER_SOURCE 才接受；相同来源管理多个客户端的实例不宣称任务隔离。

### LRS.FUNC.WATCHDOG.SUP.002

SINGLE 的完整服务在合法窗口直接刷新通道。GROUP 的各客户端完整服务在合法窗口置 SEEN_MASK 位；最后一个必需客户端服务使 mask 完整时，才刷新通道。同拍刷新后 SEEN_MASK 清零开始新轮。

验收：GROUP 非最后客户端服务不刷新；最后必需客户端完成后刷新并清 SEEN_MASK。

### LRS.FUNC.WATCHDOG.SUP.003

GROUP 在窗口开启前的完整客户端服务属于 EARLY_SERVICE；重复报到属于 DUPLICATE_CLIENT，默认记录且不贡献第二次报到。重复报到不更新 token。主超时记录 `REQUIRE_MASK & ~SEEN_MASK`。第一笔双密钥允许在窗口前开始，但完整服务仍需在窗口内完成。

验收：过早、重复、缺失分别得到规定事件和位图；重复报到不更新 token；第一密钥可提前。
