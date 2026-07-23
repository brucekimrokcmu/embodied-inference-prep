#!/usr/bin/env bash
set -euo pipefail

source_path="$1"

if ! rg -qi 'virtual|vtable|virtual table|dispatch|runtime' "${source_path}"; then
    printf 'expected a vtable explanation mentioning virtual dispatch/runtime behavior\n' >&2
    exit 1
fi
