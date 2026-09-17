# PQC LRS：生成器适用性声明

**N/A — 本 IP 的 `delivery_model = parameterized`，不使用 Generator 生成 RTL。**
参数通过 SystemVerilog elaboration parameter 形成不同配置（见
[`01_configuration.md`](01_configuration.md)），不产生结构级 RTL 生成。
参数合法性、非法配置行为、命名配置与跨参数约束均已在 CFG 类别中定义，
对应 canonical 模型为 `model/parameter_space.yaml`。