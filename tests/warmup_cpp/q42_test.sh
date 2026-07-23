#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '\\benum[[:space:]]+class[[:space:]]+Status\\b' 'enum class Status'
require_pattern "${source_path}" 'std::int[0-9]+_t|std::uint[0-9]+_t' 'fixed-width integer type'
compile_source "${source_path}" "${output_path}" "${cxx}"
