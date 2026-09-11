"""Validate resolved APB secure demux configurations against the LRS contract.

Run with the workflow uv environment. This checks configuration inputs, not RTL.
The suite owns parameter extraction and matrix generation; this script never edits
their output. Negative Elaboration cases still require an actual EDA run later.
"""

import argparse
import hashlib
import json
from pathlib import Path

import jsonschema
import yaml


def check(values):
    schema_errors, semantic_errors = [], []
    ranges = {
        "NUM_PORTS": (1, 32), "ADDR_WIDTH": (16, 32), "DATA_WIDTH": (32, 32),
        "MASTER_ID_WIDTH": (1, 16), "NUM_MASTERS": (1, 64),
        "EVENT_FIFO_DEPTH": (0, 32),
    }
    for name, (low, high) in ranges.items():
        value = values.get(name)
        if type(value) is not int or not low <= value <= high:
            schema_errors.append(f"{name}: expected integer in [{low}, {high}]")
    for name in ("REGISTER_MODE", "OUTPUT_ISOLATION_EN", "POLICY_PARITY_EN", "DFX_EN", "PUBLIC_ID_EN"):
        if type(values.get(name)) is not bool:
            schema_errors.append(f"{name}: expected boolean")
    if schema_errors:
        return "Schema", schema_errors
    ports, masters = values["NUM_PORTS"], values["NUM_MASTERS"]
    if masters > 2 ** values["MASTER_ID_WIDTH"]:
        schema_errors.append("NUM_MASTERS exceeds the complete identity encoding space")
    mask = values.get("MGMT_MASTER_MASK")
    if type(mask) is not int or not 1 <= mask < 2 ** masters:
        schema_errors.append("MGMT_MASTER_MASK: required, nonzero, within master count")
    for name, count, maximum in (
        ("PORT_BASE", ports, 2 ** 32 - 1), ("PORT_SIZE", ports, 2 ** 32),
        ("RESET_PORT_CFG", ports, 3), ("RESET_PERM", ports * masters, 255),
    ):
        data = values.get(name)
        if not isinstance(data, list) or len(data) != count:
            schema_errors.append(f"{name}: expected {count} entries")
        elif any(type(v) is not int or not 0 <= v <= maximum for v in data):
            schema_errors.append(f"{name}: invalid element")
    base = values.get("CSR_BASE")
    if type(base) is not int or not 0 <= base < 2 ** values["ADDR_WIDTH"]:
        schema_errors.append("CSR_BASE: required address within ADDR_WIDTH")
    if schema_errors:
        return "Schema", schema_errors
    intervals = [("CSR", base, 0x1000 + ports * 0x400)]
    intervals += [(f"PORT{p}", b, z) for p, (b, z) in enumerate(
        zip(values["PORT_BASE"], values["PORT_SIZE"], strict=True)
    )]
    limit = 2 ** values["ADDR_WIDTH"]
    for name, start, size in intervals:
        if start % 4 or size % 4 or size == 0:
            semantic_errors.append(f"{name}: zero size or alignment violation")
        if start + size > limit:
            semantic_errors.append(f"{name}: interval overflows ADDR_WIDTH")
    for n, first in enumerate(intervals):
        for second in intervals[n + 1:]:
            if max(first[1], second[1]) < min(first[1] + first[2], second[1] + second[2]):
                semantic_errors.append(f"overlap: {first[0]}, {second[0]}")
    return ("Elaboration", semantic_errors) if semantic_errors else (None, [])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    model = yaml.safe_load(args.model.read_text())
    rows, failures = [], 0
    for case in model["support_matrix"]["configs"]:
        values = case["params"]
        stage, errors = check(values)
        # Explicit inline schemas also apply to scalar integration fields.
        for parameter in model["parameters"]:
            if parameter.get("schema"):
                try:
                    jsonschema.validate(values.get(parameter["name"]), parameter["schema"])
                except jsonschema.ValidationError as exc:
                    stage = "Schema"
                    errors.append(f"{parameter['name']}: {exc.message}")
        expected = case.get("expect_fail", {}).get("stage")
        passed = stage == expected
        failures += not passed
        rows.append({"config_id": case["id"], "expected_failure_stage": expected,
                     "observed_failure_stage": stage, "passed": passed, "errors": errors})
    output = {
        "scope": "Configuration-only PC validation; no RTL elaboration or simulation executed",
        "model_sha256": hashlib.sha256(args.model.read_bytes()).hexdigest(),
        "checker_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        "cases": rows, "failures": failures,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, ensure_ascii=False, indent=2) + "\n")
    print(f"checked={len(rows)} failures={failures}")
    for row in rows:
        if not row["passed"]:
            print(row)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
