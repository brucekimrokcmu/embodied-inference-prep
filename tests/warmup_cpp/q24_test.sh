#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '\bstatic\b' 'a static member'
require_pattern "${source_path}" 'static[^;{]*_[[:space:]]*(=|;|\))|_[[:space:]]*(=|;)' 'trailing underscore member naming'
compile_source "${source_path}" "${output_path}" "${cxx}"
