#!/usr/bin/env python3
"""Plot a real two-dimensional Pareto scatter from comparable PPA summaries."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml

try:
    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
except ImportError:  # pragma: no cover
    print("ERROR: run with the workflow matplotlib dependency enabled", file=sys.stderr)
    sys.exit(2)

from analyze_sweep import METRICS, load_summaries, pareto_set, validate_comparable


def plot(summaries: list[dict], output: Path, metric_x: str, metric_y: str) -> None:
    if metric_x == metric_y or metric_x not in METRICS or metric_y not in METRICS:
        raise ValueError(f"choose two distinct metrics from: {', '.join(METRICS)}")
    validate_comparable(summaries)
    frontier = pareto_set(summaries)
    frontier_ids = {point["run_id"] for point in frontier}
    dominated = [point for point in summaries if point["run_id"] not in frontier_ids]

    fig, ax = plt.subplots(figsize=(8, 6))
    if dominated:
        ax.scatter(
            [float(point[metric_x]) for point in dominated],
            [float(point[metric_y]) for point in dominated],
            marker="x",
            label="dominated",
        )
    ordered = sorted(frontier, key=lambda point: float(point[metric_x]))
    ax.plot(
        [float(point[metric_x]) for point in ordered],
        [float(point[metric_y]) for point in ordered],
        marker="o",
        label="Pareto frontier",
    )
    for point in summaries:
        ax.annotate(
            f"{point['config_id']}@{float(point['clock_freq_mhz']):g}",
            (float(point[metric_x]), float(point[metric_y])),
            textcoords="offset points",
            xytext=(4, 5),
        )
    ax.set_xlabel(f"{metric_x} ({METRICS[metric_x]} is better)")
    ax.set_ylabel(f"{metric_y} ({METRICS[metric_y]} is better)")
    ax.set_title("PPA Pareto frontier")
    ax.grid(True, linestyle="--", alpha=0.4)
    ax.legend()
    fig.tight_layout()
    output.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output, dpi=150)
    plt.close(fig)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--summaries-dir", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--metric-x", default="area_um2", choices=tuple(METRICS))
    parser.add_argument("--metric-y", default="slack_ns", choices=tuple(METRICS))
    args = parser.parse_args()
    try:
        summaries = load_summaries(args.summaries_dir)
        plot(summaries, args.output, args.metric_x, args.metric_y)
    except (OSError, ValueError, yaml.YAMLError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote {args.output} ({len(summaries)} comparable points)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
