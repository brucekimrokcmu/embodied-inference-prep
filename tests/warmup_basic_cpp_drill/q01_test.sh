#!/usr/bin/env bash
set -euo pipefail

source_path="$1"
output_path="$2"
cxx="$3"

"${cxx}" -std=c++20 -Wall -Wextra -pedantic "${source_path}" -o "${output_path}"
actual="$("${output_path}")"

if [[ "${actual}" != "Hello, C++" ]]; then
    printf 'expected "Hello, C++", got "%s"\n' "${actual}" >&2
    exit 1
fi
