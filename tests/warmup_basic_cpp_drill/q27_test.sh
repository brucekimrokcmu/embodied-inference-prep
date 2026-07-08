#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" 'std::vector[[:space:]]*<' 'std::vector usage'
require_pattern "${source_path}" '\\bpush_back\\b|\\bemplace_back\\b' 'append operation'
require_pattern "${source_path}" '\bfor[[:space:]]*\([^;:]+:' 'range-based for loop'
compile_source "${source_path}" "${output_path}" "${cxx}"
