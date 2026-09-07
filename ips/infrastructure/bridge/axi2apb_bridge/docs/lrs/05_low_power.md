# 低功耗需求 - AXI-to-APB Bridge (X2P)

> **类别状态：N/A - 参数裁剪实现，无电源域**

X2P 通过参数化裁剪（功能 generate-out）实现功耗优化，不定义独立的低功耗
状态机、唤醒通道或电源域管理。整体掉电 / 断链由 SoC 层电源管理负责。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*