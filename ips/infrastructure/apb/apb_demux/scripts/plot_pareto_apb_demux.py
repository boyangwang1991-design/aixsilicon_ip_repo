#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""plot_pareto_apb_demux.py — 生成 28nm PPA Pareto 图（面积 vs 功耗）。"""
import yaml
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pathlib import Path

IP = Path.cwd()
sweep = sorted((IP / "reports/ppa").glob("summary_*.yaml"))
xs, ys, labels = [], [], []
for s in sweep:
    d = yaml.safe_load(s.read_text(encoding="utf-8"))
    if d.get("area_um2") is None or d.get("dyn_power_uW") is None:
        continue
    xs.append(float(d["area_um2"]))
    ys.append(float(d["dyn_power_uW"]))
    labels.append(str(d.get("config_id", s.stem)))

fig, ax = plt.subplots(figsize=(7, 5))
if xs:
    ax.scatter(xs, ys, c="steelblue", s=80, zorder=3)
    for x, y, lab in zip(xs, ys, labels):
        ax.annotate(lab, (x, y), textcoords="offset points", xytext=(8, 6), fontsize=9)
ax.set_xlabel("Area (um^2)")
ax.set_ylabel("Dynamic Power (uW)")
ax.set_title("APB Demux PPA (28nm GF CMOS28LP + ARM SC9, 400MHz, tt_nominal_max_1p00v_25c)")
ax.grid(True, alpha=0.3)
fig.tight_layout()
out = IP / "reports/ppa/pareto_area_power.png"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out, dpi=150)
print(f"Wrote {out}")
