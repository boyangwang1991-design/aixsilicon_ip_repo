# -*- coding: utf-8 -*-
import re
p = "rtl/x2p_top.sv"
s = open(p, encoding="utf-8").read()

# 替换解码块中的 ar_desc_q/aw_desc_q 分支为原始 te_take_rd/wr 分支
old_rd_desc = """    if (ar_desc_vld_q) begin"""
new_rd_desc = """    if (te_take_rd) begin"""
if old_rd_desc in s:
    s = s.replace(old_rd_desc, new_rd_desc)

# 将 ar_desc_q 引用还原 ar_q_dout
s = s.replace("ar_desc_q[", "ar_q_dout[")
s = s.replace("aw_desc_q[", "aw_q_dout[")
# 移除 aw_desc_vld_q 分支（还原 te_take_wr）
s = s.replace("""    end else if (aw_desc_vld_q) begin""", """    end else if (te_take_wr) begin""")

open(p, "w", encoding="utf-8").write(s)
print("decode fixed; ar_desc_q refs:", s.count("ar_desc_q"), "aw_desc_vld:", s.count("aw_desc_vld_q"))