#!/usr/bin/env python3
"""Validate comparability, compute a PPA Pareto set, and select within explicit budgets."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Any

import yaml

METRICS = {
    "area_um2": "min",
    "slack_ns": "max",
    "dyn_power_uW": "min",
    "leak_power_nW": "min",
}


def load_summaries(directory: Path) -> list[dict[str, Any]]:
    summaries = []
    for path in sorted(directory.glob("summary_*.yaml")):
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError(f"{path}: expected a YAML mapping")
        data["_source"] = str(path)
        summaries.append(data)
    if len(summaries) < 2:
        raise ValueError("a PPA sweep requires at least two summary points")
    return summaries


def validate_comparable(summaries: list[dict[str, Any]]) -> None:
    reference = summaries[0].get("comparison_context")
    if not isinstance(reference, dict):
        raise ValueError(f"{summaries[0]['_source']}: missing comparison_context")
    for summary in summaries:
        missing = [metric for metric in METRICS if summary.get(metric) is None]
        if missing:
            raise ValueError(f"{summary['_source']}: missing metrics: {', '.join(missing)}")
        if not summary.get("timing_constrained"):
            raise ValueError(f"{summary['_source']}: timing is not constrained")
        if summary.get("comparison_context") != reference:
            raise ValueError(f"{summary['_source']}: comparison context differs from the first point")
        if not summary.get("run_id") or len(summary.get("raw_reports", {})) != 3:
            raise ValueError(f"{summary['_source']}: run_id or raw report bindings are incomplete")
        if not summary.get("manifest", {}).get("sha256") or not all(
            summary["raw_reports"].get(kind, {}).get("sha256")
            for kind in ("area", "timing", "power")
        ):
            raise ValueError(f"{summary['_source']}: manifest/report hashes are incomplete")


def dominates(left: dict[str, Any], right: dict[str, Any]) -> bool:
    no_worse = []
    strictly_better = []
    for metric, direction in METRICS.items():
        a, b = float(left[metric]), float(right[metric])
        no_worse.append(a <= b if direction == "min" else a >= b)
        strictly_better.append(a < b if direction == "min" else a > b)
    return all(no_worse) and any(strictly_better)


def pareto_set(summaries: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [point for point in summaries if not any(dominates(other, point) for other in summaries if other is not point)]


def analyze(
    summaries: list[dict[str, Any]],
    objective: str,
    max_area: float | None,
    min_slack: float | None,
    max_power: float | None,
) -> dict[str, Any]:
    validate_comparable(summaries)
    frontier = pareto_set(summaries)
    feasible = [
        point
        for point in frontier
        if (max_area is None or float(point["area_um2"]) <= max_area)
        and (min_slack is None or float(point["slack_ns"]) >= min_slack)
        and (max_power is None or float(point["dyn_power_uW"]) <= max_power)
    ]
    if not feasible:
        raise ValueError("no Pareto point satisfies the declared consumer budgets")
    objective_metric, direction = {
        "area": ("area_um2", "min"),
        "power": ("dyn_power_uW", "min"),
        "slack": ("slack_ns", "max"),
    }[objective]
    recommended = sorted(
        feasible,
        key=lambda point: (
            float(point[objective_metric]) * (1 if direction == "min" else -1),
            str(point["run_id"]),
        ),
    )[0]
    return {
        "schema_version": "2.0",
        "schema": "ip-ppa-sweep-analysis/1.0",
        "point_count": len(summaries),
        "comparison_context": summaries[0]["comparison_context"],
        "metric_directions": METRICS,
        "pareto_run_ids": [point["run_id"] for point in frontier],
        "budgets": {
            "max_area_um2": max_area,
            "min_slack_ns": min_slack,
            "max_dyn_power_uW": max_power,
        },
        "objective": objective,
        "recommended_run_id": recommended["run_id"],
        "recommended_config_id": recommended["config_id"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--summaries-dir", required=True, type=Path)
    parser.add_argument("--objective", required=True, choices=("area", "power", "slack"))
    parser.add_argument("--max-area-um2", type=float)
    parser.add_argument("--min-slack-ns", type=float)
    parser.add_argument("--max-dyn-power-uW", type=float)
    parser.add_argument("--output", type=Path, default=Path("reports/ppa/sweep_analysis.yaml"))
    args = parser.parse_args()
    try:
        result = analyze(
            load_summaries(args.summaries_dir),
            args.objective,
            args.max_area_um2,
            args.min_slack_ns,
            args.max_dyn_power_uW,
        )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(yaml.safe_dump(result, allow_unicode=True, sort_keys=False), encoding="utf-8")
    except (OSError, ValueError, yaml.YAMLError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Wrote {args.output} ({result['point_count']} points, recommendation={result['recommended_run_id']})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
