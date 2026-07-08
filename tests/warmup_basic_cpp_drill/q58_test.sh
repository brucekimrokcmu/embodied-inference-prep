#!/usr/bin/env bash
set -euo pipefail

source_path="$1"

if ! rg -qi 'condition_variable|condition variable|wait|notify|mutex|state' "${source_path}"; then
    printf 'expected a condition_variable explanation\n' >&2
    exit 1
fi
