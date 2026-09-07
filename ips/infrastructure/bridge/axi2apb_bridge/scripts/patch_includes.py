# -*- coding: utf-8 -*-
import os

base = "verification/tc"
for fname in ["tc_sanity.sv", "tc_burst.sv", "tc_timeout.sv"]:
    p = os.path.join(base, fname)
    s = open(p, encoding="utf-8").read()
    # 移除 include "tc_base.sv" 行（tc_base.sv 已由 Makefile 先行编译）
    lines = [l for l in s.splitlines(keepends=True) if 'include "' not in l or "tc_base.sv" not in l]
    open(p, "w", encoding="utf-8").write("".join(lines))
    print("patched:", p)