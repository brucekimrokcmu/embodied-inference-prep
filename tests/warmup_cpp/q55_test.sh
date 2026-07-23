#!/usr/bin/env bash
set -euo pipefail

source_path="$1"

if ! rg -qi 'module|import|header|include|compile|translation' "${source_path}"; then
    printf 'expected a modules-vs-headers explanation\n' >&2
    exit 1
fi
