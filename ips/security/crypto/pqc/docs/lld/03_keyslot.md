# PQC KEYSLOT 授权元数据与撤销微架构

### LLD.MOD.PQC.KEYSLOT

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KEYSLOT
name: pqc_key_slots
parent_ref: HLD.MOD.PQC.KEYSLOT
hld_ref:
- HLD.MOD.PQC.KEYSLOT
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.003
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_key_slots
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 边界与存储

本模块只存 `KEY_SLOT_NUM` 项授权元数据，不存私钥、随机种子或任何 share。
工作态材料只在 WORKKEY；长期所有权只在外部 Key Manager。以下为待实现设计，
不能用现有 RTL 的 slot 数组或历史 UT 证明授权链已经接通。

每项保存 valid、owner[7:0]、domain[7:0]、algorithm[3:0]、pset[3:0]、usage[7:0]、
exportable、persistent、generation[15:0]、reference_active、destroy_pending、
exhausted。handle 固定为 `{generation[15:0],owner[7:0],slot[7:0]}`。
slot 越界先拒绝，禁止截断 slot 索引后访问数组。CSR 只能提交管理请求，不能直接
写 owner/domain/usage/valid；新授权来自已验证的专用 Key Manager 头。

generation 下界独立于 valid。销毁先使 valid=0，再将 generation 加一；重新分配
要求可信头的 generation 严格大于当前下界，因此 destroy/reallocate 各跨一个代次。
销毁后下界若已达 65535，则置 exhausted，拒绝本复位周期内重新分配，不能回绕。普通 zeroize
不清 generation 下界或 exhausted；冷复位后仍须外部 Key Manager 新授权，系统不得
将冷复位解释为旧会话复活。persistent 只允许 warm reset 保留授权元数据，不保留材料。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KEYSLOT.AUTH
module_ref: LLD.MOD.PQC.KEYSLOT
input_width: 32
output_width: 1
operators:
- unsigned_slot_range_check
- full_handle_compare
- owner_domain_algorithm_pset_usage_compare
- generation_saturating_advance
representation: authorization_metadata_only
req_ref:
- LRS.SEC.PQC.SLOT.001
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.006
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 请求、响应与授权重检

KEYSLOT 的管理和 acquire/release 接口均使用 valid/ready，所有身份和请求类型在
接受沿锁存。一个待响应寄存器保证响应背压时不重复受理；响应 token 包含 TOP 分配的
command_epoch[31:0] 和 request_id[31:0]。正常请求在 E0 接受，E1 注册结果；若结果
未退休则禁止接受下一请求。查询返回元数据快照，权限失败返回清零数据和公开错误。

acquire 同时校验 valid、完整 handle、可信 owner/domain、algorithm/pset、usage
包含所需操作、无 destroy_pending、无已占用引用、无 exhausted；还必须取得 WORKKEY
对相同身份和 epoch 的 READY。KEYSLOT 通过仅为条件之一，FE 不能据此绕过材料授权。
acquire 成功锁存唯一 active_epoch；单命令架构下最多一个活动引用。

每次材料请求仍由 WORKKEY 重检完整身份，KEYSLOT 向 TOP 提供撤销电平而非一次性
软件许可。同拍 revoke 与 acquire/read/custody_ACK 时，撤销组合门控先关闭授权，
下一沿作废响应 valid 和引用，不允许旧成功响应在背压后恢复。release 只接受匹配的
active_epoch；迟到 release 不释放新命令引用，也不触发 pending destroy。

## 生命周期 FSM

FSM 为单个 slot 的逻辑状态；实现为每项状态位及一个串行管理请求端口，避免复制
整套比较器。未命中的 slot 不改变。invalid-state 检查覆盖全部项。

<!-- LLD_FSM_META
id: LLD.FSM.PQC.KEYSLOT.LIFETIME
module_ref: LLD.MOD.PQC.KEYSLOT
encoding: binary
reset_state: INVALID
states: [INVALID, READY, HELD, DESTROY_PENDING, REVOKING, EXHAUSTED]
illegal_state_handling: fatal
req_ref:
- LRS.SEC.PQC.SLOT.002
- LRS.SEC.PQC.SLOT.003
- LRS.SEC.PQC.SLOT.007
applicability:
  expr: 'true'
transitions:
- {source: INVALID, destination: READY, condition: trusted_new_generation_and_authorized_metadata_commit}
- {source: READY, destination: HELD, condition: acquire_fire_and_full_identity_and_material_match}
- {source: HELD, destination: READY, condition: matching_release_and_not_destroy_pending_and_not_same_cycle_destroy}
- {source: HELD, destination: REVOKING, condition: matching_release_and_authorized_destroy_same_cycle}
- {source: HELD, destination: DESTROY_PENDING, condition: authorized_software_destroy}
- {source: DESTROY_PENDING, destination: REVOKING, condition: matching_release}
- {source: READY, destination: REVOKING, condition: authorized_software_destroy}
- {source: READY, destination: REVOKING, condition: revoke_or_global_clear_priority}
- {source: HELD, destination: REVOKING, condition: revoke_or_global_clear_priority}
- {source: DESTROY_PENDING, destination: REVOKING, condition: revoke_or_global_clear_priority}
- {source: INVALID, destination: REVOKING, condition: global_clear_priority}
- {source: REVOKING, destination: INVALID, condition: matching_material_wipe_ack_and_generation_not_exhausted}
- {source: REVOKING, destination: EXHAUSTED, condition: matching_material_wipe_ack_and_generation_exhausted}
END_LLD_FSM_META -->

未列出的条件保持状态。exhausted 项只响应查询与全局清除，不接受新分配；清除不
解除 exhausted。REVOKING 进入时撤销 valid、清敏感授权寄存器并推进 generation
一次，持续 clear 不能逐拍递增。只在相同 clear_epoch 的 WORKKEY 擦除应答后释放；
若该 slot 不驻留材料，由 TOP 的材料归属比较产生有身份绑定的空操作应答。

软件 destroy 被活动引用阻挡时只置 pending，不破坏当前密码运算；拒绝新的 acquire
和 metadata replacement。外部 revoke、tamper、fatal、zeroize 和生命周期变化则
无条件抢占，不等当前命令结束。优先序为冷复位、强制撤销/clear、已接受事务的完成、
匹配 release 与软件 destroy 的合并处理、acquire、查询/分配。release 与 destroy
同拍时先释放引用再执行销毁，直接进入 REVOKING，不能丢掉 destroy。所有冲突使用公开身份/事件，
不依赖私钥值。

## 复位、错误和资源代价

冷复位异步清 valid/响应/reference，释放后由独立清除路径等待材料擦除；此期间
管理查询只返回无效状态。warm reset 立即撤销全部 active_epoch 并清 WORKKEY；
允许保留的 persistent 元数据仍不能单独使材料 READY。其他项按上述销毁路径处理。
非法 FSM、元数据完整性失败、generation 回绕企图升级为内部错误；权限不匹配为
公开配置错误，绝不返回“部分匹配”的字段或私钥信息。

每项 54 bit 基础元数据，另加 32-bit 引用 epoch、完整性位与控制状态；最终 bit 总账
随 RTL 字段编码核算，不把其计入 8 KiB Key RAM。比较器按管理端口共享，单次判定
一拍组合比较加一拍响应；对外背压不承诺固定结束时间。现有 CSR 的 8-bit generation
与该合同不一致，必须在 02 阶段修正 RDL、再生成派生视图，不能在包装层偷偷改编码。

RTL TODO：`rtl/pqc_key_slots.sv` 实现完整身份/epoch、饱和代次、延迟 destroy 和
撤销优先；`rtl/pqc_top.sv` 将其与 WORKKEY 的材料授权及清除 epoch 相连。
设计模型检查范围为身份、代次和事件顺序；RTL 时序、CDC、ECC 和全秘密链验证仍未完成。
