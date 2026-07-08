#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" 'std::map[[:space:]]*<' 'std::map usage'
require_pattern "${source_path}" 'std::string' 'std::string key'
compile_source "${source_path}" "${output_path}" "${cxx}"
