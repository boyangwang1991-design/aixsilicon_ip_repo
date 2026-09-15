#!/usr/bin/env python3
"""Reject raw execution evidence in the IP repository's Git index."""
from pathlib import Path
import subprocess


def prohibited(path: str) -> bool:
    parts = Path(path).parts
    if not parts or parts[0] != "ips":
        return False
    if "evidence" in parts or "build" in parts:
        return True
    if "reports" not in parts:
        return False
    report = parts[parts.index("reports") + 1:]
    return bool(report) and (
        report[0] in {"preflight", "uvm"}
        or "raw" in report[:-1]
        or Path(report[-1]).suffix in {".log", ".txt", ".rpt", ".html", ".exit"}
    )


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    paths = subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=root, text=True
    ).split("\0")
    violations = sorted(p for p in paths if p and prohibited(p))
    if violations:
        print("ERROR: raw execution evidence must remain local; untrack these files:")
        print("\n".join(violations))
        return 1
    print("OK: no raw execution evidence in the Git index")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
