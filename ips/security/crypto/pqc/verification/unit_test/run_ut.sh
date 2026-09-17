#!/usr/bin/env bash
# =============================================================================
# run_ut.sh - PQC Module UT runner (project-adapted from the suite template)
# 用法: bash verification/unit_test/run_ut.sh [ut_name]   # 缺省跑全部 ut_*.sv
# 输出: <ip>/build/sim/run/ut/  （git 忽略，仓库卫生约定 build/）
# 判定: 各 UT 打印 "UT_<NAME>: PASS (errors=0)" 为通过；任一 FAIL 返回非 0。
# =============================================================================
set -uo pipefail
export LC_ALL=C
TOP="${IP_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
UT_DIR="$TOP/verification/unit_test"
OUT_BASE="$TOP/build/sim/run/ut"
mkdir -p "$OUT_BASE"
OUT=$(mktemp -d "$OUT_BASE/run.XXXXXXXX") || exit 1
RTL_DIR="$TOP/rtl"
VCS=${VCS:-vcs}
VLNV=aixsilicon:ip:pqc:0.1.0
CORE_NAME=${VLNV//:/_}
# Prefer the workflow's single managed environment; never create an IP venv.
if [ -z "${FUSESOC:-}" ]; then
  env_root="$TOP"
  while [ "$env_root" != / ] && [ ! -x "$env_root/.venv/bin/fusesoc" ]; do
    env_root=$(dirname "$env_root")
  done
  if [ -x "$env_root/.venv/bin/fusesoc" ]; then FUSESOC="$env_root/.venv/bin/fusesoc"
  else FUSESOC=fusesoc; fi
fi
REPORT="$TOP/build/reports/quality/module_ut_summary.md"
EDA_PROFILE=${RTL_EDA_PROFILE:-commercial-systemverilog}
TOOL_VERSION=$("$VCS" -ID 2>&1 | head -1 || true)

mkdir -p "$OUT"

# Filelist is used only for provenance and module-to-UT mapping. Compilation
# consumes the resolved filesets and include directories of the canonical core.
RTL_SOURCES=()
if [ -f "$RTL_DIR/filelist.f" ]; then
  while IFS= read -r source || [ -n "$source" ]; do
    source="${source%%//*}"
    source="${source#"${source%%[![:space:]]*}"}"
    source="${source%"${source##*[![:space:]]}"}"
    [ -n "$source" ] || continue
    case "$source" in
      -*|+*) echo "unsupported filelist directive: $source"; exit 1 ;;
      /*) ;;
      *) if [ -f "$TOP/$source" ]; then source="$TOP/$source"
         else source="$RTL_DIR/$source"; fi ;;
    esac
    [ -f "$source" ] || { echo "missing source: $source"; exit 1; }
    RTL_SOURCES+=("$source")
  done < "$RTL_DIR/filelist.f"
else
  shopt -s nullglob
  RTL_SOURCES=("$RTL_DIR"/*.sv)
fi
[ "${#RTL_SOURCES[@]}" -gt 0 ] || { echo "no RTL sources"; exit 1; }

snapshot_inputs() (
  cd "$TOP" || exit 1
  local dir source
  {
    for dir in rtl verification docs model regs constraints scripts configs generator; do
      [ ! -d "$dir" ] || find "$dir" -type f ! -path '*/__pycache__/*' ! -name quality.yaml -print0 || return 1
    done
    find . -maxdepth 1 -type f -name '*.core' -printf '%f\0' || return 1
    for source in "${RTL_SOURCES[@]}" "$UT_DIR/run_ut.sh"; do
      case "$source" in "$TOP"/*) printf '%s\0' "${source#"$TOP"/}" ;;
        *) echo "external dependency must be materialized and bound: $source" >&2; return 1 ;; esac
    done
  } | sort -zu | xargs -0 -r sha256sum
)

FROZEN="$OUT/inputs.before.sha256"
snapshot_inputs > "$FROZEN" || exit 1
inputs_unchanged() {
  local check_manifest
  check_manifest=$(mktemp "$OUT/input-check.XXXXXXXX") || return 1
  if snapshot_inputs > "$check_manifest" && cmp -s "$FROZEN" "$check_manifest"; then
    # Concurrent workers compare private snapshots, then atomically publish a
    # complete manifest. The parent repeats this after every worker has exited.
    mv "$check_manifest" "$OUT/inputs.after.sha256" || return 1
    return 0
  fi
  mv "$check_manifest" "$OUT/inputs.after.sha256" || return 1
  echo "SOURCE_CHANGED: frozen inputs differ; this run is stale"
  return 1
}
declare -A RESULTS

run_one() {
  local t="$1"
  local sv="$UT_DIR/$t.sv"
  local test_work="$OUT/$t"
  [ -f "$sv" ] || { echo "skip: $sv not found"; return 1; }
  inputs_unchanged || return 1
  mkdir -p "$test_work" || return 1
  echo "============== $t =============="
  local core_work="$test_work/$CORE_NAME/$t-vcs"
  local binary="$core_work/$CORE_NAME"
  if ! (cd "$test_work" && timeout 60 "$FUSESOC" --cores-root="$TOP" run \
        --target="$t" --tool=vcs --build-root="$test_work" --setup "$VLNV" &&
        cd "$core_work" && timeout 240 make) > "$OUT/$t.compile.log" 2>&1; then
    echo "$t COMPILE FAIL (see $OUT/$t.compile.log)"
    grep -iE "Error|syntax" "$OUT/$t.compile.log" | head -20
    return 1
  fi
  inputs_unchanged || return 1
  sha256sum "$binary" > "$OUT/$t.binary.sha256" || return 1
  local run_log="$OUT/$t.run.log"
  if ! (cd "$core_work" && timeout 600 "$binary" \
       "+VECTORS=$UT_DIR/golden/review_fix") > "$run_log" 2>&1; then
    echo "$t RUN FAIL (see $run_log)"
    tail -20 "$run_log"
    return 1
  fi
  inputs_unchanged || return 1
  grep -E "PASS|FAIL|TIMEOUT" "$run_log" | tail -20 || true
  if grep -Eq 'FAIL|TIMEOUT|Fatal:|Error:|Error-\[' "$run_log" || \
     ! grep -Fxq "UT_${t#ut_}: PASS (errors=0)" "$run_log"; then
    echo "$t SELF-CHECK FAIL (missing exact PASS or found FAIL/TIMEOUT)"
    return 1
  fi
}

if [ $# -ge 1 ]; then
  run_one "$1"
  exit $?
else
  jobs=${UT_JOBS:-1}
  if ! [[ "$jobs" =~ ^[1-9][0-9]*$ ]] || [ "$jobs" -gt 16 ]; then
    echo "UT_JOBS must be an integer from 1 to 16"
    exit 1
  fi
  rc=0
  count=0
  active_pids=()
  active_names=()
  finish_batch() {
    local i test_id
    for ((i=0; i<${#active_pids[@]}; i++)); do
      test_id=${active_names[$i]}
      if wait "${active_pids[$i]}"; then RESULTS[$test_id]=pass; else rc=1; fi
    done
    active_pids=()
    active_names=()
  }
  set -- "$UT_DIR"/ut_*.sv
  if [ ! -e "$1" ]; then
    echo "no Module UT sources found in $UT_DIR"
    rc=1
  fi
  for f in "$UT_DIR"/ut_*.sv; do
    [ -e "$f" ] || continue
    count=$((count + 1))
    test_id=$(basename "$f" .sv)
    RESULTS[$test_id]=fail
    run_one "$test_id" &
    active_pids+=("$!")
    active_names+=("$test_id")
    if [ "${#active_pids[@]}" -ge "$jobs" ]; then finish_batch; fi
  done
  finish_batch
  if ! inputs_unchanged; then
    rc=1
    for test_id in "${!RESULTS[@]}"; do RESULTS[$test_id]=fail; done
  fi
  mkdir -p "$(dirname "$REPORT")"
  status=pass
  [ "$rc" -eq 0 ] || status=fail
  {
    echo "# Module UT Summary"
    echo
    echo "<!-- REPORT_META"
    echo 'schema_version: "2.0"'
    echo "ip_name: $(basename "$TOP")"
    echo "report_type: module_ut"
    echo "status: $status"
    echo "eda_profile: $EDA_PROFILE"
    echo "tool: vcs"
    echo "tool_version: |"
    echo "  ${TOOL_VERSION:-unknown}"
    echo "test_count: $count"
    echo "command: UT_JOBS=$jobs bash verification/unit_test/run_ut.sh"
    echo "parallel_jobs: $jobs"
    echo "inputs_manifest:"
    echo "  path: ${FROZEN#"$TOP"/}"
    echo "  sha256: $(sha256sum "$FROZEN" | awk '{print $1}')"
    echo "inputs_after_manifest:"
    echo "  path: ${OUT#"$TOP"/}/inputs.after.sha256"
    echo "  sha256: $(sha256sum "$OUT/inputs.after.sha256" | awk '{print $1}')"
    echo "module_coverage:"
    for source in "$UT_DIR"/ut_*.sv; do
      [ -f "$source" ] || continue
      test_id=$(basename "$source" .sv)
      module_name="${test_id#ut_}"
      if grep -Eq "^[[:space:]]*module[[:space:]]+((automatic|static)[[:space:]]+)?${module_name}([[:space:]#;(]|$)" "${RTL_SOURCES[@]}"; then
        echo "  $module_name: [$test_id]"
      fi
    done
    echo "artifacts:"
    for test_id in "${!RESULTS[@]}"; do
      echo "  $test_id: ${RESULTS[$test_id]}"
    done | sort
    echo "END_REPORT_META -->"
  } > "$REPORT"

  echo
  echo "===== Module UT summary: $status (${count} tests) ====="
  for test_id in $(echo "${!RESULTS[@]}" | tr ' ' '\n' | sort); do
    printf '  %-34s %s\n' "$test_id" "${RESULTS[$test_id]}"
  done
  echo "Report: ${REPORT#"$TOP"/}"
  echo "Run dir: ${OUT#"$TOP"/}"
  exit $rc
fi