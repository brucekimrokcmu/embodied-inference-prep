#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/test_helpers.sh"

source_path="$1"
output_path="$2"
cxx="$3"

require_pattern "${source_path}" '\\bclass[[:space:]]+Shape\\b|\\bstruct[[:space:]]+Shape\\b' 'Shape base type'
require_pattern "${source_path}" '\\bclass[[:space:]]+Circle[[:space:]]*:[[:space:]]*public[[:space:]]+Shape\\b|\\bstruct[[:space:]]+Circle[[:space:]]*:[[:space:]]*public[[:space:]]+Shape\\b' 'Circle deriving publicly from Shape'
compile_source "${source_path}" "${output_path}" "${cxx}"
