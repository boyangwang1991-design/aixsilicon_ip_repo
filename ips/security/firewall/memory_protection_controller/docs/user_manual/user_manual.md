# AXI MPU - 用户手册（User Manual）

> **IP**: `axi_mpu` · **Version**: `1.0.0`

## 1. 功能简介

AXI MPU 对经过它的 AXI4 事务执行基于 Region 的访问控制。合法事务透明
转发至下游；非法事务在本地终结并返回 DECERR，同时记录 violation 并可
产生中断。

## 2. 权限模型

```
ALLOW = region_match
     && master_allowed        (MASTER_MASK)
     && master_security_valid (MASTER_ATTR capability)
     && security_allowed      (SECURE/NONSECURE_ALLOW)
     && privilege_allowed     (PRIV/UNPRIV_ALLOW)
     && operation_allowed     (READ/WRITE/EXECUTE_ALLOW)
```

- Region 匹配要求整个 burst 范围落在 `[BASE, LIMIT]` 内；
- Region overlap 时 lowest index wins；
- 无 Region 命中 → Default Deny。

## 3. 编程模型（APB4）

### 3.1 寄存器总览

| Offset | 名称 | 说明 |
|---|---|---|
| 0x000 | GLOBAL_CTRL | global_enable |
| 0x004 | GLOBAL_STATUS | global_lock 状态回读 |
| 0x008 | GLOBAL_LOCK | 全局锁（woset：写 1 置位，仅复位清除） |
| 0x00C | IRQ_ENABLE | viol_en |
| 0x010 | IRQ_STATUS | viol_sticky（W1C） |
| 0x020 | VIOL_STATUS | valid / read / write / instr / secure / priv（W1C） |
| 0x024 | VIOL_ADDR_LO | 首错地址 [31:0]（FIRST_ERROR_STICKY） |
| 0x028 | VIOL_ADDR_HI | 首错地址 [47:32] |
| 0x02C | VIOL_INFO0 | master_id / axi_id / region_id / reason |
| 0x034 | VIOL_COUNT | violation 计数（饱和） |
| 0x100+i*4 | MASTER_ATTR[i] | bit0 secure_capable, bit1 nonsecure_capable |
| 0x200+i*0x40 | REGION[i] | CTRL/BASE_LO/HI/LIMIT_LO/HI/MASK/PERM |

### 3.2 配置流程示例

```c
/* 1. 关闭全局使能，配置 Region0: 0x1000-0x1FFF，仅 CPU0（master0）读写 */
APB_WR(0x200 + 0x00, 0x00000000);        /* REGION0.CTRL: enable=0, lock=0 */
APB_WR(0x200 + 0x04, 0x00001000);        /* BASE_LO */
APB_WR(0x200 + 0x08, 0x00000000);        /* BASE_HI */
APB_WR(0x200 + 0x0C, 0x00001FFF);        /* LIMIT_LO */
APB_WR(0x200 + 0x10, 0x00000000);        /* LIMIT_HI */
APB_WR(0x200 + 0x14, 0x00000001);        /* MASK: master0 */
APB_WR(0x200 + 0x18, 0x0000007D);        /* PERM: sec|priv|unpriv|R|W|X */
APB_WR(0x200 + 0x00, 0x00000001);        /* enable */

/* 2. 冻结配置 */
APB_WR(0x008, 0x00000001);               /* GLOBAL_LOCK (woset) */

/* 3. 违例处理：读 VIOL_STATUS/VIOL_INFO*，写 1 清 IRQ_STATUS/VIOL_STATUS */
```

### 3.3 Region PERMISSION 位定义

| bit | 字段 |
|---|---|
| 0 | secure_allow |
| 1 | nonsecure_allow |
| 2 | priv_allow |
| 3 | unpriv_allow |
| 4 | read_allow |
| 5 | write_allow |
| 6 | exec_allow |

## 4. 中断处理

1. `irq` 拉高（IRQ_ENABLE.viol_en=1 且发生 violation）；
2. 读 VIOL_STATUS / VIOL_INFO0 定位首错；
3. 写 1 清 IRQ_STATUS.viol_sticky；
4. 写 1 清 VIOL_STATUS.valid（同时清除 sticky 快照使能下次首错捕获）。

## 5. 错误响应约定

- 读违规：RRESP=DECERR，RDATA=0，beat 数与 ARLEN 匹配，RLAST 正常；
- 写违规：BRESP=DECERR，对应 W beats 被本地消费，下游无部分写入；
- 锁定后的配置写被静默忽略（swwe gate），返回 OKAY。

## 6. 已知限制

- Master identity 依赖系统 sideband 正确性；
- mid-transaction 的上游 R backpressure 场景由下游模型固定延迟覆盖，
  专项 backpressure 压测待 agent 架构增强（见 review_findings note 项）。
