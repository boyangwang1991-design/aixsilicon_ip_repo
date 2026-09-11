# Lint diagnostic review

Existing SpyGlass report: 0 Fatal / 0 Error; no tool waivers. This inventory is historical until a fresh run binds current RTL inputs.

| Rule | Source owner | Count |
|---|---|---|
| DetectTopDesignUnits | handwritten-RTL | 1 |
| ElabSummary | tool | 1 |
| STARC05-1.3.1.3 | handwritten-RTL | 1 |
| STARC05-2.1.4.5 | handwritten-RTL | 1 |
| STARC05-2.10.3.2a | handwritten-RTL | 1 |
| STARC05-2.2.3.3 | handwritten-RTL | 2 |
| SYNTH_5064 | CBB | 2 |
| W240 | native-generated | 2 |
| W240 | tool | 1 |
| W415a | handwritten-RTL | 253 |
| W415a | native-generated | 1676 |
| W528 | handwritten-RTL | 3 |
| W528 | structural-generated | 810 |
| W528 | tool | 1 |
| checkCMD_ignore01 | tool | 1 |

## Disposition and remaining checks

- CBB SYNTH_5064: simulation assertions excluded from synthesis. UT keeps these enabled after reset initialization. This is not a formal proof.
- AsyncResetOtherUse: top-level reset isolation intentionally gates externally visible outputs. SoC reset distribution/release evidence remains open.
- C_PUBLIC_ID_EN logical-width warnings: generated configuration is a 64-bit constant constrained to 0/1. Boolean comparison cleanup is pending; no suppression applied.
- Events InitValUsingNBA: clear is followed by a same-cycle selected-event assignment, implementing event-wins behavior. Depth 0/1/3/32 UT covers snapshot collisions.
- Native W240: wrapper owns ACCESS and protection authorization; native block receives an already qualified request. Bridge and CSR tests verify rejected requests have no command side effects.
- W415a: inventory includes default-then-override combinational logic, reduction loops, generated decode and priority updates. Review per source/line remains required before lint signoff; this report does not blanket-waive 1929 messages.
- W528: inventory retains unused structural/native signals. Verify each unused response/payload is superseded by captured and validated wrapper context before accepting; no blanket waiver.

Current module UT result: reports/quality/module_ut_summary.md (ten tests passed). UVM, formal and final parameter-space execution remain separate requirements.
