#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/software
cc -std=c11 -Wall -Wextra -Werror -Isw/include sw/watchdog.c sw/tests/test_watchdog.c -o build/software/test_watchdog
build/software/test_watchdog
