# AXI Memory Protection Unit — 安全需求（SEC）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 安全需求

### 1.1 攻击面防范

#### LRS.SEC.AXI_MPU.ATTACK.001 未授权访问防范

<!-- LRS_META
id: LRS.SEC.AXI_MPU.ATTACK.001
category: SEC
feature: attack_surface
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-004
applicability:
  expr: "true"
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

IP 必须重点防范：未授权 Master access、Non-secure→Secure Region、
Unprivileged→Privileged Region、Write→Read-only Region、instruction access→NX
Region、Burst crossing protection boundary、forged Secure AxPROT、invalid Master
ID、configuration tampering、Region overlap ambiguity、default allow、AXI denied
transaction deadlock。

#### Acceptance Criteria

- 上述每种攻击场景均被拒绝；
- forged Secure AxPROT（非 Secure-capable Master 声明 secure）被拒绝；
- 无 default allow 路径。

---

### 1.2 配置安全

#### LRS.SEC.AXI_MPU.CONFIG_SEC.001 配置接口安全

<!-- LRS_META
id: LRS.SEC.AXI_MPU.CONFIG_SEC.001
category: SEC
feature: config_security
priority: P0
status: active
source_ref:
  - SRC-001
  - SRC-004
applicability:
  expr: "true"
verification_method:
  - review
  - simulation
END_LRS_META -->

#### Requirement

AXI MPU 本身不能保证 APB 配置总线的访问安全。系统必须确保 Only trusted
software / trusted master 能访问 MPU configuration interface。MPU 自身提供
Region Lock 与 Global Lock 作为第二层配置保护。

#### Acceptance Criteria

- Region/Global Lock 防止配置篡改；
- 文档明确配置接口依赖系统级访问控制。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 01-lrs-author*
