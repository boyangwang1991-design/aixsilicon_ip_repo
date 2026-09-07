# -*- coding: utf-8 -*-
s = open("verification/tc/tc_sanity.sv", encoding="utf-8").read()
old = """    // 1) 只读事务（定位读路径）
    `uvm_info(get_type_name(), "Read-only smoke", UVM_LOW)
    do_axi_read(32'h1000, 4'h1);
    do_axi_write(32'h1000, 64'hDEAD_BEEF_CAFE_F00D, 8'hFF, 4'h1);
    do_axi_read(32'h1000, 4'h1);"""
new = """    // 1) 写事务（先验证写路径）
    do_axi_write(32'h1000, 64'hDEAD_BEEF_CAFE_F00D, 8'hFF, 4'h1);
    // 2) 读事务
    do_axi_read(32'h1000, 4'h1);
    // 3) 再次写 + 读（验证连续）
    do_axi_write(32'h2000, 64'h1234_5678_9ABC_DEF0, 8'hFF, 4'h2);
    do_axi_read(32'h2000, 4'h2);"""
assert old in s, "pattern not found"
s = s.replace(old, new)
open("verification/tc/tc_sanity.sv", "w", encoding="utf-8").write(s)
print("reordered ok")