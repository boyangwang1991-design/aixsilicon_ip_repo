# HLD 风险、检查清单与附录 - UART

## 18. 架构风险

| 风险 | 等级 | 缓解 |
|---|---|---|
| APB 接入引入的桥接时序风险 | 中 | apb2tlul 独立验证 + 时序约束 |
| 核心代码与 RDL 地址一致性漂移 | 低 | RDL 为权威源，publish_csr 校验 |
| 波特率 NCO 取整误差（低波特率高时钟） | 低 | 文档约束 + 边界测试 |

## 19. 评审检查清单

| 检查项 | 状态 |
|---|---|
| 需求全覆盖（must → HLD 模块） | 待验证（extractor 校验） |
| 外部/内部接口定义完整 | 待验证 |
| 时钟/复位/电源域定义 | ✅ |
| CDC 路径（无） | ✅ |
| 寄存器与 RDL 一致 | ✅ |

## 20. 附录

### 设计 ID 规范

```text
HLD.MOD.L1.UART / HLD.MOD.L2.UART.<SUB> / HLD.IF.EXT.UART.<IF> / HLD.DOM.UART.<DOM>
```

### 输出物清单

| 产物 | 路径 |
|---|---|
| 架构模型 | `model/architecture.yaml` |
| 外部接口模型 | `model/external_interface.yaml` |
| 内部接口模型 | `model/internal_interface.yaml` |
| 时钟域模型 | `model/clock_domains.yaml` |
| CDC 路径模型 | `model/cdc_paths.yaml` |

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 03-hld-architect*
