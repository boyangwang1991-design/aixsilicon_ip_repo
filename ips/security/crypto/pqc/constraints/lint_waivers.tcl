# SpyGlass SGDC waiver rules for the PQC accelerator (G3 lint/lint_rtl).
#
# This file is read by SpyGlass as an SGDC (waiver) source, so it may only
# contain valid SGDC commands. Every waiver below records the rule and the
# structural reason. Waiving a lint rule never waives the corresponding
# functional requirement: those are covered by the Module UT and the UVM
# verification plan. The waivers are scoped per file on purpose; a blanket
# waiver would hide a real finding introduced elsewhere.
#
# Actual G3 status is recorded by the current run. The waivers below are
# coding-style findings that the LLD microarchitecture deliberately accepts.

# ---------------------------------------------------------------------------
# Generated CSR (PeakRDL output - never hand-edited, see 02-reg-model).
# ---------------------------------------------------------------------------
# Wide-field decode assigns a default then overrides per field in one always
# block. That is the generator's single-procedural-driver style, not a race.
waive -rule W415a -file "*pqc_csr.sv"
# Valid-address decode bits are computed for every access and consumed only by
# the accesses that need them; unused forms are inherent to full decode.
waive -rule W528 -file "*pqc_csr.sv"
# Per-field storage enable is intentionally always-on because the write enable
# is applied through the field's load_next/we term.
waive -rule FlopEConst -file "*pqc_csr.sv"
# APB control inputs (penable/pprot) are part of the fixed interface signature;
# the CSR block only needs psel/pwrite for access qualification.
waive -rule W240 -file "*pqc_csr.sv"

# ---------------------------------------------------------------------------
# One-process FSM / default-then-override coding style.
# The LLD microarchitecture coding contract allows a single clocked process that
# carries both the state register and its next-state logic, and combinational
# blocks that assign a safe default and then override it conditionally.
# ---------------------------------------------------------------------------
waive -rule STARC05-2.2.3.3 -file "*pqc_keccak.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_work_key_ram.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_cmd_frontend.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_dsa_seq.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_fault_ctrl.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_kem_seq.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_key_slots.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_secure_sram_ctrl.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_secded_functions.svh"

waive -rule STARC05-2.11.3.1 -file "*pqc_axi_read_arb.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_cmd_frontend.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_codec.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_desc_fetch.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_dma.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_dsa_seq.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_keccak.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_kem_seq.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_poly_engine.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_sampler.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_work_key_ram.sv"

waive -rule W415a -file "*pqc_top.sv"
waive -rule W415a -file "*pqc_desc_validate.sv"
waive -rule W415a -file "*pqc_keccak.sv"
waive -rule W415a -file "*pqc_work_key_ram.sv"
waive -rule W415a -file "*pqc_key_slots.sv"
waive -rule W415a -file "*pqc_cmd_frontend.sv"
waive -rule W415a -file "*pqc_dsa_seq.sv"
waive -rule W415a -file "*pqc_fault_ctrl.sv"
waive -rule W415a -file "*pqc_kem_seq.sv"
waive -rule W415a -file "*pqc_sampler.sv"
waive -rule W415a -file "*pqc_secure_sram_ctrl.sv"
waive -rule W415a -file "*pqc_poly_engine.sv"
waive -rule W415a -file "*pqc_secded_functions.svh"

# ---------------------------------------------------------------------------
# Unused observations / spare interface signals.
# The top level exposes implementation and status observations that this
# revision does not consume, and keeps the full external interface signature
# (fixed by the LRS/HWIF contract) even where a field is not yet used.
# ---------------------------------------------------------------------------
waive -rule W528 -file "*pqc_top.sv"
waive -rule W528 -file "*pqc_secure_sram_ctrl.sv"
waive -rule W528 -file "*pqc_keccak.sv"
waive -rule W240 -file "*pqc_cmd_frontend.sv"
waive -rule W240 -file "*pqc_top.sv"
waive -rule W240 -file "*pqc_apb_if.sv"
waive -rule W240 -file "*pqc_ecc_sram.sv"
waive -rule W240 -file "*pqc_key_slots.sv"
waive -rule W240 -file "*pqc_secure_sram_ctrl.sv"
# Top-level instance outputs that are intentionally left unobserved; the
# observing checks live in the module UTs for those modules.
waive -rule W287b -file "*pqc_top.sv"

# ---------------------------------------------------------------------------
# Arithmetic / constant-folding style in the NTT and Keccak data paths.
# ---------------------------------------------------------------------------
waive -rule W426 -file "*pqc_poly_engine.sv"
waive -rule W426 -file "*pqc_keccak.sv"
waive -rule STARC05-2.1.3.1 -file "*pqc_poly_engine.sv"
waive -rule STARC05-2.1.3.1 -file "*pqc_keccak.sv"
waive -rule W362 -file "*pqc_codec.sv"
waive -rule W362 -file "*pqc_dma.sv"
waive -rule W362 -file "*pqc_keccak.sv"
waive -rule W362 -file "*pqc_sampler.sv"
waive -rule W216 -file "*pqc_keccak.sv"
waive -rule W224 -file "*pqc_secded_functions.svh"
waive -rule STARC05-2.1.5.3 -file "*pqc_secded_functions.svh"
waive -rule W339a -file "*pqc_dma.sv"
waive -rule FlopEConst -file "*pqc_key_slots.sv"
waive -rule SYNTH_5059 -file "*pqc_dma.sv"
waive -rule SYNTH_5143 -file "*pqc_top.sv"
# Warm-reset-qualified accept gates new traffic out of POR-retained transport.
# This is a coding-style waiver only; it does NOT waive or close CDC/RDC checks.
waive -rule STARC05-1.3.1.3 -file "*pqc_cmd_frontend.sv"
# Intentional synthesis-only SRAM interface, selected by the lint target.
# Only storage is blackboxed; control/ECC remain visible and array behavior is
# checked by simulation. This waiver does not apply to any logic module.
waive -rule WarnAnalyzeBBox -file "*/rtl/synthesis/pqc_ecc_sram.sv"

# 2026-09-18 review: classify 240 warnings from source-px0msrzs.
# No synthesis error, latch, loop, range, or undriven-output rule is waived.
# 单时序进程FSM；状态寄存器和条件更新有同一procedural owner。
waive -rule STARC05-2.11.3.1 -file "*pqc_dsa_keygen.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_dsa_sign.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_dsa_verify.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_kem_decaps.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_kem_encaps.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_kem_keygen.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_key_custody.sv"
waive -rule STARC05-2.11.3.1 -file "*pqc_top.sv"
# 同一时序进程内默认递增/清零与状态动作按非阻塞赋值优先级覆盖，非多驱动。
waive -rule STARC05-2.2.3.3 -file "*pqc_dsa_keygen.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_dsa_sign.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_dsa_verify.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_kem_keygen.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_key_custody.sv"
waive -rule STARC05-2.2.3.3 -file "*pqc_top.sv"
# 非掩码确定性Decaps保留统一entropy端口但不消费随机数；Level2集成仍开放。
waive -rule W240 -file "*pqc_kem_decaps.sv"
# Verify的8-bit hint/omega与16-bit计数器作无符号比较，SV零扩展为16位；没有截断或符号扩展。
waive -rule W362 -file "*pqc_dsa_verify.sv"
# 同一时序进程的默认赋值与后续状态分支覆盖，优先级有意保留。
waive -rule W415a -file "*pqc_dsa_keygen.sv"
waive -rule W415a -file "*pqc_dsa_sign.sv"
waive -rule W415a -file "*pqc_dsa_verify.sv"
waive -rule W415a -file "*pqc_kem_keygen.sv"
waive -rule W415a -file "*pqc_key_custody.sv"
# 无延迟/无事件的automatic task仅由唯一always_ff调用；宏式复用寄存器赋值，不产生并发进程。
waive -rule W426 -file "*pqc_dsa_keygen.sv"
waive -rule W426 -file "*pqc_dsa_sign.sv"
waive -rule W426 -file "*pqc_dsa_verify.sv"
waive -rule W426 -file "*pqc_kem_decaps.sv"
waive -rule W426 -file "*pqc_kem_encaps.sv"
waive -rule W426 -file "*pqc_kem_keygen.sv"
# 锁存的pset及Decaps entropy_word不参与当前串行路径，工具可移除；不是缺省连接的功能输出。
waive -rule W528 -file "*pqc_dsa_verify.sv"
waive -rule W528 -file "*pqc_kem_decaps.sv"
