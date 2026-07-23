#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" 'std::mutex\\b' 'std::mutex usage'
require_pattern "${source_path}" 'std::lock_guard|std::scoped_lock|\.lock[[:space:]]*\(' 'mutex locking'
compile_source "${source_path}" "${output_path}" "${cxx}"
