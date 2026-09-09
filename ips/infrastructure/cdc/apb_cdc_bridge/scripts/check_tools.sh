#!/usr/bin/env bash
# Usage: RTL_EDA_PROFILE=commercial-systemverilog bash scripts/check_tools.sh \
#          --report reports/quality/env_check_report.md

set -u

PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
missing=0
REPORT=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        --report)
            [ "$#" -ge 2 ] || {
                echo "ERROR: --report requires a path" >&2
                exit 2
            }
            REPORT="$2"
            shift 2
            ;;
        *)
            echo "ERROR: unsupported argument: $1" >&2
            exit 2
            ;;
    esac
done

if [ -n "$REPORT" ]; then
    mkdir -p "$(dirname "$REPORT")"
    exec > >(tee "$REPORT") 2>&1
fi

check_tool() {
    local tool="$1"
    local version_arg="$2"
    local version_output
    local first_line
    if command -v "$tool" >/dev/null 2>&1; then
        if version_output="$("$tool" "$version_arg" 2>&1)"; then
            first_line="${version_output%%$'\n'*}"
            printf "  PASS %-14s %s\n" "$tool" "$first_line"
        else
            printf "  FAIL %-14s version command failed\n" "$tool"
            missing=1
        fi
    else
        printf "  MISSING %s\n" "$tool"
        missing=1
    fi
}

echo "EDA profile: $PROFILE"
case "$PROFILE" in
    commercial-systemverilog)
        check_tool vcs -ID
        # NOTE: 不要用 `verdi -v` / `dc_shell -ver`，会拉起 GUI 导致脚本挂起（实测坑点）
        check_tool verdi -help
        check_tool spyglass -version
        check_tool dc_shell -version
        check_tool vc_formal -h
        ;;
    open-source-exploration)
        check_tool verilator --version
        check_tool iverilog -V
        check_tool yosys -V
        check_tool sby --version
        ;;
    *)
        echo "ERROR: unsupported RTL_EDA_PROFILE: $PROFILE" >&2
        exit 2
        ;;
esac

echo "Python environment:"
if ! command -v uv >/dev/null 2>&1; then
    echo "  MISSING uv"
    exit 1
fi
uv --version
if [ ! -f "$PROJECT_DIR/pyproject.toml" ]; then
    echo "  MISSING $PROJECT_DIR/pyproject.toml"
    exit 1
fi
if [ ! -f "$PROJECT_DIR/uv.lock" ]; then
    echo "  MISSING $PROJECT_DIR/uv.lock"
    exit 1
fi
(
    cd "$PROJECT_DIR"
    uv run python --version
    uv run python -c "import yaml; print('  PASS pyyaml', yaml.__version__)"
)

exit "$missing"
