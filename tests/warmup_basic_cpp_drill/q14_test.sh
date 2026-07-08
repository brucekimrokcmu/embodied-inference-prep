#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '\\bfriend\\b' 'friend function usage'
require_pattern "${source_path}" '\\bprivate\\b' 'a private field'
compile_source "${source_path}" "${output_path}" "${cxx}"
