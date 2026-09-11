# Watchdog：服务序列与身份

## 客户端服务序列

<!-- LLD_FSM_META
id: LLD.FSM.WATCHDOG.CHANNEL.SERVICE
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.FUNC.WATCHDOG.SUP.001
- LRS.FUNC.WATCHDOG.SUP.002
- LRS.FUNC.WATCHDOG.SUP.003
- LRS.FUNC.WATCHDOG.SUP.004
- LRS.FUNC.WATCHDOG.SUP.005
- LRS.FUNC.WATCHDOG.SUP.006
- LRS.FUNC.WATCHDOG.SUP.007
- LRS.FUNC.WATCHDOG.SUP.008
- LRS.FUNC.WATCHDOG.SUP.009
- LRS.FUNC.WATCHDOG.SUP.010
applicability:
  expr: 'true'
encoding: binary
reset_state: EMPTY
illegal_state_policy: fatal
illegal_state_handling: detect illegal encoding/protection mismatch, block normal mutation and latch fatal request
states:
- EMPTY
- WAIT_SECOND
transitions:
- source: EMPTY
  condition: valid KEY1 in DUAL
  target: WAIT_SECOND
- source: WAIT_SECOND
  condition: same source KEY2 within inclusive limit
  target: EMPTY
- source: WAIT_SECOND
  condition: wrong/repeated key or expiry
  target: EMPTY
- source: ANY
  condition: restart/stop/fault
  target: EMPTY
- source: ANY
  condition: otherwise
  target: same
END_LLD_FSM_META -->

执行前依次检查运行状态、SERVICE_PATH、client<NUM_CLIENTS 且被 REQUIRE_MASK 选中、
可信来源等于 OWNER_SOURCE、所需授权与 event_type。PAUSED 返回 PAUSED，其他非
运行返回 BAD_STATE；身份/授权/路径拒绝记录 ACCESS_ERROR，不推进序列或形成完整服务。

SINGLE_KEY 比较 KEY1。DUAL_KEY 每客户端 pending/source/seq_age 独立：首笔 KEY1
记年龄0；以后未暂停边沿先候选年龄 sat(age+1)，第二笔在1..SEQ_LIMIT内且身份一致
才完成。达到 SEQ_LIMIT 当拍若无合法第二笔则 SEQUENCE_TIMEOUT；重复第一笔、无
第一笔的第二笔或错值产生 BAD_KEY_SEQUENCE 并清 pending。普通合法读写不打断。

TOKEN 与 QA 使用每客户端32位 token。重启 seed=0x1D872B41 xor(ch<<8)xor(client)，
结果0时改1；QA响应为 ROL32(token,7)xor0x6D2B79F5 xor(ch<<8)xor(client)。成功完整
客户端贡献后 token=(token>>1)xor(token[0]?0x80200003:0)，错误/重复GROUP不更新。
TOKEN/QA 读取来自快照，不能读时推进。算法不提供密码学身份认证。

完整算法通过后继续检查候选主窗口、重复报到、ALIVE最大次数及所有同拍故障；仅
最终 accepted 才增加 service_seq 和更新 token/客户端。主超时/Deadline优先，失败
不能先更新 token 再以故障覆盖状态。刷新清本轮客户端状态但保留更新后token；重启重新播种。

