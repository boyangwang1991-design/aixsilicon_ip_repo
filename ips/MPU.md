# AXI Memory Protection Unit — Requirement & Architecture Specification

> **IP Name**: `axi_mpu`
> **Category**: Security / Interconnect Protection
> **Target Version**: `1.0.0`
> **IP Type**: Generator IP + Runtime Configurable Protection Table
> **Primary Interface**: AXI4
> **Configuration Interface**: APB4
> **Status**: Draft Baseline

---

# 1. Purpose

AXI Memory Protection Unit（AXI MPU）用于在 AXI Master 与目标 Slave / Interconnect 之间提供基于地址和访问上下文的访问控制。

AXI MPU 根据以下信息判断访问是否合法：

* AXI Address；
* Read / Write 访问类型；
* `AxPROT`：

  * Secure / Non-secure；
  * Privileged / Unprivileged；
  * Instruction / Data；
* Master Identity；
* 可选 Domain ID / User-defined Context；
* Region 配置的访问权限。

对于合法访问，AXI MPU 将事务透明转发至下游。

对于非法访问，AXI MPU不得将对应事务发送至受保护的下游 Slave，并在本地完成 AXI transaction，返回错误响应，同时可记录 violation 信息并产生中断。

AXI MPU 的目标是实现：

> **Region-based、Default-Deny、Context-aware 的 AXI System Access Control。**

---

# 2. Scope

AXI MPU V1.0 支持：

* AXI4 Full；
* AXI4 burst；
* Read / Write protection；
* 多地址 Region；
* Runtime Region 配置；
* Secure / Non-secure；
* Privileged / Unprivileged；
* Read / Write / Execute 属性；
* Master ID 权限；
* Master Security Attribution；
* Region Priority；
* Burst Boundary Protection；
* 多 outstanding transaction；
* 非法访问本地 DECERR；
* Violation Logging；
* Violation Interrupt；
* Region Lock；
* Global Lock；
* APB4 配置接口；
* 可配置 pipeline；
* Generator 结构裁剪。

---

# 3. Non-Goals

V1.0 不要求实现：

* CPU MMU 页表转换；
* Virtual Address → Physical Address Translation；
* TLB；
* Cache coherency；
* AXI protocol firewall；
* AXI timeout protection；
* AXI deadlock recovery；
* ECC；
* IOMMU/SMMU；
* PASID；
* PCIe ATS；
* 完整虚拟化 translation。

AXI MPU 属于：

> **Access Protection**

而不是：

> **Address Translation / Protocol Firewall**

---

# 4. Typical Deployment

推荐 AXI MPU 主要部署于受保护 Slave 侧。

```text
CPU ----\
DMA -----\
NPU ------+---- AXI Interconnect ---- AXI MPU ---- Protected SRAM
HAC -----/
```

典型保护对象：

* Secure SRAM；
* ROM；
* Boot Memory；
* Key RAM；
* Safety RAM；
* Security Subsystem；
* Critical Register Space；
* DDR protected window；
* Shared Accelerator Memory。

也允许部署于 Master 侧：

```text
Master
  |
AXI MPU
  |
Interconnect
```

但 V1.0 不依赖特定部署位置。

---

# 5. Design Principles

## 5.1 Default Deny

AXI MPU 应采用：

```text
Default Deny
+
Explicit Allow
```

未匹配任何有效 Region 的访问默认拒绝。

Reset 后所有可编程 Region 默认 disabled。

---

## 5.2 Independent Permission Dimensions

以下访问属性必须独立建模：

```text
Address
Master Identity
Security State
Privilege State
Operation Type
```

不得将 Master 和 Security State 直接编码为组合权限矩阵。

最终权限判断：

```text
ALLOW =
    region_match
  && master_allowed
  && master_security_valid
  && security_allowed
  && privilege_allowed
  && operation_allowed
```

---

## 5.3 Master Identity 与 Security 独立

Master Identity 表示：

> 谁在访问。

Security State 表示：

> 当前 transaction 以何种安全属性进行访问。

同一个 Master 可以同时具有：

```text
Secure access capability
Non-secure access capability
```

Region 权限分别判断 Master 和 Security。

---

# 6. Request Context

每个 AXI transaction 应被转换成统一内部 Request Context。

```text
RequestContext
{
    address
    read_write
    axi_id
    master_id

    secure
    privileged
    instruction

    optional_domain_id

    burst_type
    burst_len
    burst_size

    burst_start
    burst_end
}
```

Read 使用：

```text
ARADDR
ARPROT
ARID
ARBURST
ARLEN
ARSIZE
```

Write 使用：

```text
AWADDR
AWPROT
AWID
AWBURST
AWLEN
AWSIZE
```

---

# 7. Master Identity

AXI `AxID` 默认不得作为 Master Identity。

原因是：

```text
AxID = Transaction ID
```

其语义不等价于：

```text
Requester / Master Identity
```

AXI MPU 应提供独立 Master Context，例如：

```text
MASTER_ID
```

或者通过系统定义的 AXI USER sideband 传递。

推荐内部统一表示为：

```text
request.master_id
```

Generator 应支持：

```text
MASTER_ID_WIDTH
MASTER_NUM
```

---

# 8. Master Security Attribution

仅依赖 `AxPROT[1]` 不足以保证 Master 身份可信。

因此 AXI MPU 应支持 Master Security Attribution。

每个 Master 可配置：

```text
SECURE_CAPABLE
NONSECURE_CAPABLE
```

例如：

```text
CPU0:
    Secure = Yes
    Non-secure = Yes

DMA0:
    Secure = No
    Non-secure = Yes

HSM:
    Secure = Yes
    Non-secure = No
```

若：

```text
request.secure == Secure
```

而：

```text
MASTER_ATTR[master_id].SECURE_CAPABLE == 0
```

则访问必须拒绝。

因此：

```text
master_security_valid =
    requested_security
    is permitted for this master
```

Master Security Attribution 和 Region Security Permission 是两个独立检查阶段。

---

# 9. Protection Region

AXI MPU 包含 N 个 Protection Region。

Generator 参数：

```text
REGION_NUM
```

推荐支持：

```text
4
8
16
32
```

但实现不得假设 REGION_NUM 必须是 2 的幂。

每个 Region 至少包含：

```text
REGION_ENABLE
REGION_BASE
REGION_LIMIT

MASTER_MASK

SECURE_ALLOW
NONSECURE_ALLOW

PRIVILEGED_ALLOW
UNPRIVILEGED_ALLOW

READ_ALLOW
WRITE_ALLOW
EXECUTE_ALLOW

REGION_LOCK
```

---

# 10. Address Region Model

V1.0 采用：

```text
BASE + LIMIT
```

模式。

Region match：

```text
REGION_BASE <= ADDRESS <= REGION_LIMIT
```

Region 必须定义：

```text
BASE <= LIMIT
```

非法 Region 配置不得导致未定义硬件行为。

推荐：

```text
invalid region
=> region considered disabled
```

---

# 11. Region Match

对于 Region `i`：

```text
region_match[i] =
    REGION_ENABLE[i]
 && address >= REGION_BASE[i]
 && address <= REGION_LIMIT[i]
```

Burst transaction 必须同时满足完整 burst address range 位于 Region 内。

即：

```text
burst_start >= REGION_BASE
&&
burst_end <= REGION_LIMIT
```

不能只判断 `ARADDR/AWADDR` 首地址。

---

# 12. Burst Protection

AXI MPU V1.0 支持：

```text
INCR
FIXED
WRAP
```

Generator 可以允许裁剪 WRAP 支持，但 FULL AXI4 Profile 默认支持。

MPU 必须计算 transaction 涉及的有效地址范围。

如果一个 burst 跨越：

```text
Region Boundary
```

则默认：

```text
DENY WHOLE TRANSACTION
```

不得允许：

```text
部分 beat 合法
部分 beat 非法
```

的 transaction 继续进入下游。

这是 AXI MPU 的核心安全要求之一。

---

# 13. Region Priority

允许 Region overlap。

Region 优先级固定定义为：

```text
Lowest Region Index Wins
```

例如：

```text
Region0 > Region1 > Region2 > ... > RegionN-1
```

若一个 transaction 同时命中多个 Region：

```text
selected_region =
    lowest-index matching region
```

该规则必须确定且不可依赖综合实现。

这样允许实现：

```text
Large Default Region
+
Small Exception Region
```

---

# 14. Master Permission

每个 Region 包含：

```text
MASTER_MASK[MASTER_NUM-1:0]
```

例如：

```text
MASTER_MASK = 8'b0000_0101
```

表示：

```text
Master0 allowed
Master2 allowed
```

其它 Master denied。

判断：

```text
master_allowed =
    MASTER_MASK[request.master_id]
```

非法 Master ID：

```text
master_id >= MASTER_NUM
```

必须被拒绝。

---

# 15. Security Permission

Region 独立支持：

```text
SECURE_ALLOW
NONSECURE_ALLOW
```

从而允许：

```text
Secure only
Non-secure only
Secure + Non-secure
Neither
```

Region Security Permission 不负责判断 Master 是否具有声明该 Security State 的资格。

该判断由：

```text
Master Security Attribution
```

完成。

---

# 16. Privilege Permission

使用 `AxPROT[0]`。

Region 独立提供：

```text
PRIVILEGED_ALLOW
UNPRIVILEGED_ALLOW
```

因此可表达：

```text
Privileged only
Unprivileged only
Both
None
```

---

# 17. Read / Write / Execute Permission

Region 提供：

```text
READ_ALLOW
WRITE_ALLOW
EXECUTE_ALLOW
```

Read transaction：

```text
requires READ_ALLOW
```

Write transaction：

```text
requires WRITE_ALLOW
```

Instruction access 可结合：

```text
AxPROT[2]
```

检查 `EXECUTE_ALLOW`。

但 MPU 规格必须明确：

> Execute permission 属于 system-level secondary protection，不替代 CPU MMU/MPU 的 architectural execute permission。

推荐逻辑：

```text
if instruction_access:
    requires READ_ALLOW && EXECUTE_ALLOW
else:
    requires READ_ALLOW
```

---

# 18. Permission Decision

完整权限判断：

```text
selected_region = priority_encode(region_match)

if no region match:
    DENY
else:
    ALLOW =
        master_allowed
     && master_security_valid
     && security_allowed
     && privilege_allowed
     && operation_allowed
```

建议内部产生：

```text
deny_reason
```

包括：

```text
NO_REGION
MASTER_DENY
MASTER_SECURITY_DENY
SECURITY_DENY
PRIVILEGE_DENY
READ_DENY
WRITE_DENY
EXECUTE_DENY
BURST_BOUNDARY_DENY
INVALID_CONTEXT
```

---

# 19. Read Transaction Handling

合法 Read：

```text
AR
 |
Protection Check
 |
ALLOW
 |
forward AR
 |
downstream R
 |
forward R upstream
```

非法 Read：

```text
AR
 |
Protection Check
 |
DENY
 |
do NOT send AR downstream
 |
local error responder
 |
RRESP = DECERR
```

非法 burst read 必须按照 AXI transaction 语义完成上游 transaction。

推荐 local responder 返回对应 transaction 所需 beat 数量，并正确产生：

```text
RID
RVALID
RRESP
RLAST
```

所有非法 read beat：

```text
RRESP = DECERR
```

`RDATA` 推荐固定为：

```text
0
```

---

# 20. Write Transaction Handling

Write path 必须考虑 AXI AW/W channel 解耦。

合法：

```text
AW
 |
Protection Check
 |
ALLOW
 |
forward AW

W beats
 |
forward downstream
```

非法：

```text
AW
 |
Protection Check
 |
DENY
 |
do NOT send AW downstream
 |
consume corresponding W beats
 |
discard WDATA
 |
generate B response locally
```

返回：

```text
BRESP = DECERR
```

必须确保非法 Write transaction 不会造成：

* W channel deadlock；
* 后续 transaction 串扰；
* AW/W ownership 丢失；
* 下游部分写入。

---

# 21. Write Tracking Queue

为正确支持 multiple outstanding write，AXI MPU 应维护 Write Decision Queue。

每个 Entry 至少记录：

```text
AWID
AWLEN
ALLOW/DENY
selected_region
```

根据体系需要还可记录：

```text
deny_reason
master_id
security_state
```

Write Decision Queue 必须保证 AW transaction 与后续 W beats 正确关联。

---

# 22. Multiple Outstanding

V1.0 支持多个 outstanding transaction。

Generator 参数：

```text
READ_OUTSTANDING
WRITE_OUTSTANDING
```

推荐默认：

```text
READ_OUTSTANDING  = 8
WRITE_OUTSTANDING = 8
```

可支持：

```text
1 / 2 / 4 / 8 / 16
```

具体最大值由 implementation profile 决定。

MPU 不得因为 permission check 强制 AXI 降级为单 outstanding。

---

# 23. AXI Ordering

AXI MPU 必须遵守 AXI ordering requirement。

对于合法 transaction：

```text
不得改变原有 AXI ordering semantics
```

对于非法 transaction：

```text
local response
```

仍必须满足对应 ID 的 ordering requirement。

---

# 24. Error Response

Protection violation 默认响应：

```text
DECERR
```

即：

```text
RRESP = DECERR
BRESP = DECERR
```

不得因为权限拒绝：

```text
永久拉低 READY
```

也不得造成 bus hang。

---

# 25. Violation Logging

AXI MPU V1.0 必须支持 violation capture。

至少包含：

```text
VIOL_VALID
VIOL_ADDR
VIOL_MASTER_ID
VIOL_AXID

VIOL_READ
VIOL_WRITE
VIOL_INSTRUCTION

VIOL_SECURE
VIOL_PRIVILEGED

VIOL_REGION_ID
VIOL_REASON
```

可选：

```text
VIOL_COUNT
```

---

# 26. Violation Capture Policy

V1.0 默认采用：

```text
FIRST_ERROR_STICKY
```

发生第一次错误后：

```text
VIOL_VALID = 1
```

后续错误不得覆盖首个错误信息，直到软件显式清除。

Generator 可选支持：

```text
LAST_ERROR
```

但不作为 V1.0 必需配置。

---

# 27. Violation Counter

推荐支持：

```text
VIOL_COUNT
```

每次 protection violation：

```text
count++
```

计数器应支持 saturation：

```text
MAX -> MAX
```

而不是 wrap-around。

---

# 28. Interrupt

MPU 支持：

```text
IRQ
```

当：

```text
violation interrupt enable
&&
protection violation
```

时置位。

建议采用：

```text
sticky interrupt
```

由软件：

```text
W1C
```

清除。

---

# 29. Configuration Interface

V1.0 配置接口：

```text
APB4 Slave
```

配置接口与 protected AXI datapath 独立。

典型：

```text
Secure CPU
   |
  APB
   |
AXI MPU CFG
```

---

# 30. Configuration Security

AXI MPU 本身不能保证 APB 配置总线的访问安全。

系统必须确保：

```text
Only trusted software / trusted master
```

能够访问 MPU configuration interface。

MPU 自身提供：

```text
Region Lock
Global Lock
```

作为第二层配置保护。

---

# 31. Region Lock

每个 Region 支持：

```text
REGION_LOCK
```

置位后，对应 Region 的：

```text
BASE
LIMIT
ATTR
MASTER_MASK
```

均不得再修改。

推荐：

```text
REGION_LOCK:
    write 0 -> no effect
    write 1 -> lock
```

Lock 仅通过 reset 清除。

---

# 32. Global Lock

提供：

```text
GLOBAL_LOCK
```

置位后：

```text
all protection configuration frozen
```

包括：

```text
Region Configuration
Master Attribution
Global Protection Policy
```

Violation status / interrupt clear 等运行态寄存器仍允许软件访问。

GLOBAL_LOCK：

```text
0 -> 1 allowed
1 -> 0 prohibited
```

仅 reset 清除。

---

# 33. Reset Behavior

Reset 后必须：

```text
all regions disabled
default policy = DENY
locks cleared
violation status cleared
interrupt cleared
```

因此 reset 后 AXI protected datapath 默认：

```text
deny all protected access
```

直到 trusted software 完成 MPU 初始化。

---

# 34. Optional Boot Bypass

考虑部分 SoC boot-flow，Generator 可提供：

```text
BOOT_BYPASS
```

但：

```text
BOOT_BYPASS = false
```

应为默认配置。

若启用，必须有明确、不可由 non-secure software 控制的退出机制。

V1.0 不推荐默认启用。

---

# 35. Pipeline

Permission Engine 应支持：

```text
0-stage / combinational
1-stage pipeline
```

Generator 可根据：

```text
REGION_NUM
ADDR_WIDTH
MASTER_NUM
Target Frequency
```

选择实现。

目标是支持：

```text
1 AXI address request / cycle
```

不得因为 region matching 引入不必要 bubble。

---

# 36. Permission Engine Architecture

推荐内部架构：

```text
                 Request Context
                       |
                       v
              +----------------+
              | Burst Analyzer |
              +-------+--------+
                      |
                      v
              +----------------+
              | Region Matcher |
              +-------+--------+
                      |
                      v
              +----------------+
              | Priority Select|
              +-------+--------+
                      |
                      v
          +-------------------------+
          | Permission Checker      |
          |                         |
          | Master                  |
          | Master Security         |
          | Secure / Non-secure     |
          | Privileged / User       |
          | R / W / X               |
          +------------+------------+
                       |
                ALLOW / DENY
```

---

# 37. Region Matcher Architecture

对于 Region `i`：

```text
match[i] =
    enable[i]
 &&
    start_addr >= base[i]
 &&
    end_addr <= limit[i]
```

所有 Region 可并行比较。

之后：

```text
Priority Encoder
```

选择最高优先级 Region。

---

# 38. Architecture Optimization

Generator 应允许根据 Region 数选择不同结构。

例如：

```text
REGION_NUM <= 4:
    Flat comparator

REGION_NUM <= 16:
    Parallel comparator
    + priority tree

REGION_NUM > 16:
    Hierarchical match
    + optional pipeline
```

具体 threshold 属于 implementation policy，不构成 architectural software contract。

---

# 39. Recommended Register Model

建议寄存器空间：

```text
0x000 GLOBAL_CTRL
0x004 GLOBAL_STATUS
0x008 GLOBAL_LOCK
0x00C IRQ_ENABLE
0x010 IRQ_STATUS
0x014 IRQ_CLEAR

0x020 VIOL_STATUS
0x024 VIOL_ADDR_LO
0x028 VIOL_ADDR_HI
0x02C VIOL_INFO0
0x030 VIOL_INFO1
0x034 VIOL_COUNT
```

Master attribution：

```text
0x100 MASTER_ATTR[0]
0x104 MASTER_ATTR[1]
...
```

Region：

```text
REGION_STRIDE = implementation defined
```

例如：

```text
REGION0_BASE_LO
REGION0_BASE_HI
REGION0_LIMIT_LO
REGION0_LIMIT_HI

REGION0_MASTER_MASK

REGION0_PERMISSION
REGION0_CONTROL
```

---

# 40. REGION_PERMISSION

逻辑字段：

```text
SECURE_ALLOW
NONSECURE_ALLOW

PRIV_ALLOW
UNPRIV_ALLOW

READ_ALLOW
WRITE_ALLOW
EXEC_ALLOW
```

这些字段必须保持独立。

不得实现为：

```text
MASTER0_SECURE_RW
MASTER0_NONSECURE_R
MASTER1_SECURE_RW
...
```

这种笛卡尔积式 permission table。

---

# 41. MASTER_ATTR

每个 Master 支持：

```text
SECURE_CAPABLE
NONSECURE_CAPABLE
```

未来版本可扩展：

```text
TRUST_LEVEL
DOMAIN
SAFETY_DOMAIN
VMID
```

V1.0 不要求实现以上扩展。

---

# 42. Static vs Runtime Configuration

AXI MPU Generator 负责：

```text
决定硬件有什么
```

例如：

```text
REGION_NUM
MASTER_NUM
ADDR_WIDTH
DATA_WIDTH
ID_WIDTH
OUTSTANDING
HAS_EXECUTE
HAS_MASTER_ATTR
HAS_IRQ
HAS_VIOLATION_LOG
PIPELINE
```

Runtime Registers 负责：

```text
当前系统怎么配置
```

例如：

```text
REGION_BASE
REGION_LIMIT
MASTER_MASK
SECURE_ALLOW
NONSECURE_ALLOW
PRIVILEGE
RWX
```

必须明确：

> Generator 不应把普通 Region 地址与访问策略直接硬编码进 RTL，除非选择 Static Region Profile。

---

# 43. Generator Model

推荐 Generator 输入：

```yaml
axi_mpu:
  interface:
    protocol: axi4
    addr_width: 48
    data_width: 128
    id_width: 8

  protection:
    region_num: 16
    master_num: 8

    secure: true
    privilege: true
    execute: true

    master_identity: true
    master_security_attribution: true

  region:
    runtime_configurable: true
    address_mode: base_limit
    overlap_policy: lowest_index_wins

  transaction:
    read_outstanding: 8
    write_outstanding: 8

    fixed_burst: true
    incr_burst: true
    wrap_burst: true

    burst_boundary_check: true

  violation:
    logging: true
    irq: true
    counter: true
    capture_policy: first_error

  configuration:
    interface: apb4

  implementation:
    pipeline: auto
```

---

# 44. Generator Architecture

推荐：

```text
YAML Configuration
        |
        v
Python Config Parser
        |
        v
Hardware IR / Graph
        |
        +-------------------+
        |                   |
        v                   v
SV Configuration        Register Model
Generation              Generation
        |                   |
        +---------+---------+
                  |
                  v
           SV Backend
                  |
                  v
             FuseSoC Core
```

---

# 45. RTL Organization

推荐：

```text
rtl/
├── axi_mpu.sv
├── axi_mpu_pkg.sv
├── axi_mpu_read.sv
├── axi_mpu_write.sv
├── axi_mpu_permission.sv
├── axi_mpu_region_match.sv
├── axi_mpu_error_resp.sv
├── axi_mpu_violation.sv
├── axi_mpu_regs.sv
└── axi_mpu_master_attr.sv
```

不建议为了形式化复用过度拆分 CBB。

---

# 46. AXI MPU Top-Level Architecture

```text
                       +-----------------------+
                       |       AXI MPU         |
                       |                       |
S_AXI_AR ------------->| Read Frontend         |
                       |        |              |
                       |        v              |
                       |  Protection Engine    |
                       |     /       \         |
                       | ALLOW       DENY      |
                       |   |           |       |
                       |   v           v       |
                       | M_AXI_AR   Local R     |
                       |             DECERR     |
                       |                       |
S_AXI_AW ------------->| Write Frontend        |
S_AXI_W -------------->|        |              |
                       |        v              |
                       |  Protection Engine    |
                       |     /       \         |
                       | ALLOW       DENY      |
                       |  |            |       |
                       | AW/W       Consume W  |
                       |  |         Local B    |
                       |  |         DECERR     |
                       +--|--------------------+
                          |
                          v
                        M_AXI


                +----------------------+
ADDR ---------->|                      |
AxPROT -------->| Protection Engine    |
MASTER_ID ----->|                      |
R/W/X -------->|                      |
                +----------------------+

                     ^
                     |
                 Region Table
                     ^
                     |
                   APB4
```

---

# 47. Performance Requirements

设计目标：

```text
Allow-path throughput:
    >= 1 address transaction / cycle
```

对于 permission check：

* 不应固定引入 bubble；
* pipeline latency 可参数化；
* Read / Write path 独立；
* permission engine 可逻辑共享或物理复制；
* 不要求 V1.0 固定 zero-latency。

建议 Generator 根据 timing / area profile 决定：

```text
shared permission engine
```

或：

```text
independent read/write permission engines
```

---

# 48. PPA Profiles

建议支持：

## AREA

```text
shared permission engine
small outstanding queue
minimal violation logging
optional pipeline
```

## BALANCED

```text
parallel read/write path
moderate outstanding
parallel region compare
1-stage optional pipeline
```

## PERFORMANCE

```text
independent AR/AW protection engine
parallel region comparators
hierarchical priority tree
pipeline enabled
large outstanding
```

---

# 49. Functional Safety Considerations

若用于功能安全场景，可在未来 Profile 增加：

```text
configuration register parity
region table parity
lockstep checker
violation escalation
fault injection
safety interrupt
```

但不作为 MPU V1.0 baseline 强制要求。

---

# 50. Security Considerations

必须重点防范：

* 未授权 Master access；
* Non-secure → Secure Region；
* Unprivileged → Privileged Region；
* Write → Read-only Region；
* instruction access → NX Region；
* Burst crossing protection boundary；
* forged Secure AxPROT；
* invalid Master ID；
* configuration tampering；
* Region overlap ambiguity；
* default allow；
* AXI denied transaction deadlock。

---

# 51. Verification Requirements

至少覆盖以下类别。

## Region

* no region match；
* single region match；
* multiple region overlap；
* priority；
* BASE；
* LIMIT；
* boundary ±1；
* invalid BASE/LIMIT。

## Master

* allowed Master；
* denied Master；
* invalid Master ID。

## Security

* Secure allow；
* Secure deny；
* Non-secure allow；
* Non-secure deny；
* forged Secure transaction；
* Master Security Attribution violation。

## Privilege

* Privileged allow/deny；
* Unprivileged allow/deny。

## Operation

* Read；
* Write；
* Execute；
* NX violation。

## Burst

* burst fully inside；
* cross BASE；
* cross LIMIT；
* cross Region；
* INCR；
* FIXED；
* WRAP。

## AXI

* multiple IDs；
* multiple outstanding；
* backpressure；
* independent AW/W；
* local DECERR；
* downstream stall；
* reset during traffic。

## Configuration

* Region lock；
* Global lock；
* illegal rewrite after lock；
* reset unlock；
* default deny。

## Violation

* first-error sticky；
* violation count；
* IRQ；
* W1C；
* simultaneous violations。

---

# 52. Recommended Assertions

建议至少包括：

```text
Denied AR shall never reach M_AXI_AR.
```

```text
Denied AW shall never reach M_AXI_AW.
```

```text
Denied W data shall never modify downstream state.
```

```text
Every accepted denied transaction shall eventually receive local error response.
```

```text
Locked region configuration shall remain stable until reset.
```

```text
GLOBAL_LOCK cannot transition 1 -> 0 except reset.
```

```text
No unmatched access may be allowed under DEFAULT_DENY.
```

---

# 53. V1.0 Feature Baseline

| Feature                      | V1.0         |
| ---------------------------- | ------------ |
| AXI4 Full                    | Required     |
| AXI4 burst                   | Required     |
| Read protection              | Required     |
| Write protection             | Required     |
| BASE/LIMIT Region            | Required     |
| Runtime Region Configuration | Required     |
| Multiple Regions             | Required     |
| Region Priority              | Required     |
| Region overlap               | Required     |
| Master ID Permission         | Required     |
| Master Security Attribution  | Required     |
| Secure / Non-secure          | Required     |
| Privileged / Unprivileged    | Required     |
| Read / Write                 | Required     |
| Execute protection           | Required     |
| Burst boundary check         | Required     |
| Multiple outstanding         | Required     |
| Local DECERR                 | Required     |
| APB4 configuration           | Required     |
| Violation log                | Required     |
| Violation IRQ                | Required     |
| Region Lock                  | Required     |
| Global Lock                  | Required     |
| Default Deny                 | Required     |
| Optional pipeline            | Required     |
| Generator flow               | Required     |
| Domain ID                    | Future       |
| VMID                         | Future       |
| PASID                        | Future       |
| Protocol Firewall            | Out of scope |
| IOMMU / SMMU                 | Out of scope |

---

# 54. Final Architecture Decision

AXI MPU V1.0 采用：

```text
Generator IP
+
Runtime Configurable Region Table
+
Independent Permission Dimensions
+
Default Deny
+
Slave-side AXI Inline Protection
```

核心权限模型：

```text
ADDRESS
   &&
MASTER
   &&
MASTER SECURITY CAPABILITY
   &&
SECURITY
   &&
PRIVILEGE
   &&
R/W/X
   ↓
ALLOW / DENY
```

其中：

> Master Identity 与 Secure / Non-secure 权限独立建模，最终通过 AND 组合形成访问授权。

Generator 负责：

```text
生成保护引擎的结构与规模
```

Runtime Configuration 负责：

```text
定义实际地址段和访问策略
```

因此：

```text
Generator determines what hardware exists.
Software determines what the protection policy is.
```

该方案应作为 AXI MPU V1.0 的基础架构原则。
