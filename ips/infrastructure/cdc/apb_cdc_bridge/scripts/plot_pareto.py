#!/usr/bin/env python3
"""plot_pareto.py — 从 sweep_summary.csv 绘制 PPA Pareto/对比图（面积/频率/功耗 × 配置）

对齐 20-ppa-optimization：Pareto 前沿 + 面积/功耗 vs 频率 对比。
输出: reports/ppa/*.png（禁 ASCII 图）。
用法: uv run python scripts/plot_pareto.py --summary evidence/ppa/<run_id>/sweep_summary.csv
"""
import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def load_summary(path: Path) -> list[dict]:
    with path.open(newline="") as f:
        return list(csv.DictReader(f))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--summary", required=True)
    ap.add_argument("--out-dir", default="reports/ppa")
    args = ap.parse_args()

    rows = load_summary(Path(args.summary))
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # 配置标签与颜色
    cfg_label = {
        "0-1-1": "HANDSHAKE",
        "1-1-1": "ASYNC_FIFO depth1",
        "1-2-2": "ASYNC_FIFO depth2",
    }
    colors = {"0-1-1": "tab:blue", "1-1-1": "tab:green", "1-2-2": "tab:red"}
    by_cfg: dict[str, list[dict]] = {}
    for r in rows:
        key = f"{r['cdc_impl']}-{r['req_depth']}-{r['rsp_depth']}"
        by_cfg.setdefault(key, []).append(r)

    # ---- 图1: 面积/功耗 vs 频率（每配置一条线）----
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))
    for key, pts in by_cfg.items():
        pts.sort(key=lambda p: float(p["freq_mhz"]))
        f = [int(p["freq_mhz"]) for p in pts]
        area = [float(p["total_area_um2"]) for p in pts]
        dyn = [float(p["dyn_power_uW"]) for p in pts]
        lab = cfg_label[key]
        ax1.plot(f, area, "-o", color=colors[key], label=lab)
        ax2.plot(f, dyn, "-s", color=colors[key], label=lab)
    ax1.set_xlabel("Frequency (MHz)")
    ax1.set_ylabel("Total Cell Area (µm²)")
    ax1.set_title("Area vs Frequency")
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    ax2.set_xlabel("Frequency (MHz)")
    ax2.set_ylabel("Dynamic Power (µW)")
    ax2.set_title("Dynamic Power vs Frequency")
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_dir / "area_power_vs_freq.png", dpi=150)
    plt.close(fig)

    # ---- 图2: Pareto（面积 vs 动态功耗，600MHz 前沿加粗）----
    fig, ax = plt.subplots(figsize=(7, 5))
    for key, pts in by_cfg.items():
        for p in pts:
            marker = "o"
            ms = 9 if int(p["freq_mhz"]) == 600 else 6
            ax.scatter(float(p["total_area_um2"]), float(p["dyn_power_uW"]),
                       c=colors[key], marker=marker, s=ms * 20,
                       label=f"{cfg_label[key]}" if p["run_tag"].endswith("50ns") else None,
                       alpha=0.85)
    # Pareto 前沿（600MHz 点，追求最小面积+功耗）
    pareto_pts = [p for p in rows if int(p["freq_mhz"]) == 600]
    pareto_pts.sort(key=lambda p: float(p["total_area_um2"]))
    if pareto_pts:
        px = [float(p["total_area_um2"]) for p in pareto_pts]
        py = [float(p["dyn_power_uW"]) for p in pareto_pts]
        ax.plot(px, py, "k--", linewidth=1.2, label="Pareto front (600MHz)")
    ax.set_xlabel("Total Cell Area (µm²)")
    ax.set_ylabel("Dynamic Power (µW)")
    ax.set_title("PPA Pareto: Area vs Dynamic Power (28nm HVT, tt)")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_dir / "pareto_area_power.png", dpi=150)
    plt.close(fig)

    print(f"Wrote {out_dir/'area_power_vs_freq.png'} , {out_dir/'pareto_area_power.png'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
