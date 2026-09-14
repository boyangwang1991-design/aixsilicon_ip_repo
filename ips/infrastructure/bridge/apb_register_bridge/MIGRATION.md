# APB Register Bridge 迁移说明

2026-09-13：原 CBB `BUS-003 / apb_register_slice` 整包迁入 IP
`MIG-IP-BUS-003 / apb_register_bridge`。该实现协调 APB SETUP/ACCESS、等待和响应，属于独立总线集成功能。

RTL 顶层、参数、测试、约束及原交付件逐字节保留。`cbb.yaml` 和原 Gate/发布 manifest
为历史 CBB 证据，当前仓库归属与状态由 registry 和 ip-package.yaml 管理。
旧 `aixsilicon:cbb:apb_register_slice:0.1.0` Core 随工程迁入，兼容既有消费标识；
消费者须注册 IP 仓库。仅有旧版 CBB 仓库的消费者需一起更新仓库基线。
当前无新 IP VLNV，不添加空 RTL 包装，也不伪造新发布资格。
下一次正式发布必须生成 IP Core、验证依赖闭包和 IP 集成契约，再完成版本迁移。

历史报告中的旧路径及哈希保留原样，不代表新路径下已重新完成全部资格验证。
