#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"
stdin_path="$4"

require_pattern "${source_path}" '\\btry\\b' 'try block'
require_pattern "${source_path}" '\\bcatch\\b' 'catch block'
compile_if_no_main_otherwise_run "${source_path}" "${output_path}" "${cxx}" "${stdin_path}"
