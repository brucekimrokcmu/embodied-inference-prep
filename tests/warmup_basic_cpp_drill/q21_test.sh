#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '\\bstatic_cast[[:space:]]*<' 'static_cast usage'
compile_source "${source_path}" "${output_path}" "${cxx}"
