#!/usr/bin/env bash
set -euo pipefail

source_path="$1"

if ! rg -qi 'multiple inheritance|ambigu|diamond|base class|object layout' "${source_path}"; then
    printf 'expected a multiple-inheritance risk explanation\n' >&2
    exit 1
fi
