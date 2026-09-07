# X2P Smoke 测试报告

<!-- REPORT_META
schema_version: "1.0"
ip_name: x2p
report_type: smoke
status: pass
eda_profile: commercial-systemverilog
vip_sha: a10f79456cff6bd1d6b01371608ee404f6a0a6f6
vip_note: "使用修改后的 apb/axi VIP（修复 P1-P5：disable fork B backfill / default ready / apb_if init / ZERO_WAIT read / config_db doc）"
tests:
  - id: tc_sanity
    status: pass
    detail: "写路径 B 响应 OKAY+正确 ID；读路径 R 返回正确数据（读路径 BUG-001 已修复）"
  - id: tc_burst
    status: pass
    detail: "INCR burst 读写 / WRAP / FIXED / 4KB 边界均完成，无错误/死锁"
  - id: tc_timeout
    status: pass
    detail: "APB 超时返回 SLVERR（suppress_pready 触发），FSM 恢复不锁死"
END_REPORT_META -->

## 运行信息

- 命令: `make compile && make regression`（`verification/sim/Makefile`，产物入 `build/sim/`）
- 编译: 成功
- VIP: `aixsilicon_vip_repo` @ `a10f794`（修改后：修复 P1-P5 + APB G4/G5 + 目录正交化）
- 日期: 2026-09-06（UTC-4）

## 结果（使用修改后的 apb/axi VIP 回归）

| 检查 | 结果 |
|---|---|
| UVM 环境编译（VCS + uvm-1.2，VIP @ a10f794） | PASS |
| 写事务 B 响应（bid 正确 + bresp OKAY） | PASS |
| 读事务 R 响应（rdata 正确 + rlast + rid） | PASS（原 BUG-001 已修复） |
| tc_burst（UVM VIP 驱动） | PASS |
| tc_timeout（suppress_pready → SLVERR） | PASS |

## 适配修改（VIP P3 修复后）

修改后 VIP 的 `apb_if` 必选信号改为纯声明（P3：消除 ICPSD），导致旧 `APB_DISABLED`
超时方案失效（pready 悬空 X → DUT timeout 计数永不递增）。已适配：

- [`x2p_env.sv`](../../verification/env/x2p_env.sv)：timeout 分支保持 `APB_ACTIVE_SLAVE`，
  不再禁用 agent；
- [`harness.sv`](../../verification/th/harness.sv)：`+X2P_APB_TIMEOUT` 时置
  `u_apb.suppress_pready=1`（VIP 提供的 PREADY 恒低机制）并关闭超时场景 SVA
  （`sva_enable=0`：DUT 超时恢复属协议异常路径，不满足 RUL-003 wait 稳定断言）。

## 缺陷闭环

- **BUG-001（读路径 R timeout）**：closed。
  根因是**响应方向位错误**：`x2p_top` 用当前 APB 请求方向 `apb_write_x` 充当响应方向
  （而非响应所属请求的方向），导致每个事务最后一个子传输的响应被误路由
  （读的最后 sub 被当作写 → 误发 B；写的最后 sub 被当作读 → R 永不完成）。
  修复：`x2p_apb_engine` 新增 `rsp_write = write_q` 输出，顶层方向位改用它。
- 另修复同类阻塞：
  - `x2p_rsp_mgr` 写侧寄存器（bresp_out_q/bid_out_q/b_pending_q/b_error_q）缺复位 → B 通道 x；
  - `x2p_rsp_mgr` 读累加器跨 beat 未清 → 窄读高 lane 携带陈旧数据；
  - `x2p_top` 多 beat 写 W 队列后续 beat 未出队 → TE 卡 ST_WAITDATA；
  - harness：SYNC 模式 pclk 与 aclk 不同源；AXI 激励 valid 0 脉宽导致无事务上总线。

## 单元测试

`verification/unit_test/`（6 个，全部 PASS）：
`ut_req_mgr` / `ut_scheduler` / `ut_transfer_engine` / `ut_apb_engine` /
`ut_rsp_mgr` / `ut_read_path`（顶层读路径集成：单拍 8B、4-beat burst、窄读 4B）。

## 结论

Smoke 标记 `pass`：编译通过，读写路径闭环，回归（sanity/burst/timeout）全绿。
G4 门禁读路径阻塞已解除。
