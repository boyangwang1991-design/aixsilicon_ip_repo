import json
import subprocess
import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    result = subprocess.run(
        [sys.executable, "-m", "pytest", "-q"], cwd=root,
        text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
    )
    report = {
        "command": "python -m pytest -q",
        "returncode": result.returncode,
        "status": "PASS" if result.returncode == 0 else "FAIL",
        "output": result.stdout.strip(),
    }
    (root / "validation_report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(result.stdout, end="")
    print(f"validation_report.json: {report['status']}")
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())

