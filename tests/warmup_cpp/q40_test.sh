#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '= *default' 'default usage'
require_pattern "${source_path}" '= *delete' 'delete usage'
require_pattern "${source_path}" '\\boverride\\b' 'override usage'
require_pattern "${source_path}" '\\bfinal\\b' 'final usage'
compile_source "${source_path}" "${output_path}" "${cxx}"
