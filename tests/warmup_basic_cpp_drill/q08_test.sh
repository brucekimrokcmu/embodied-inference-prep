#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"
stdin_path="$4"

require_pattern "${source_path}" '\\bnew\\b' 'use of new for heap allocation'
require_pattern "${source_path}" '\\bdelete\\b' 'use of delete for heap release'
compile_if_no_main_otherwise_run "${source_path}" "${output_path}" "${cxx}" "${stdin_path}"
