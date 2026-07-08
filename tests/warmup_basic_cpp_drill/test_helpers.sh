#!/usr/bin/env bash

compile_source() {
    local source_path="$1"
    local output_path="$2"
    local cxx="$3"
    "${cxx}" -std=c++20 -Wall -Wextra -pedantic -c "${source_path}" -o "${output_path}.o"
}

require_pattern() {
    local source_path="$1"
    local pattern="$2"
    local description="$3"

    if ! rg -q "${pattern}" "${source_path}"; then
        printf 'expected %s\n' "${description}" >&2
        exit 1
    fi
}

compile_if_no_main_otherwise_run() {
    local source_path="$1"
    local output_path="$2"
    local cxx="$3"
    local stdin_path="${4:-/dev/null}"

    if rg -q '(^|[[:space:]])int[[:space:]]+main[[:space:]]*\(' "${source_path}"; then
        "${cxx}" -std=c++20 -Wall -Wextra -pedantic "${source_path}" -o "${output_path}"
        "${output_path}" < "${stdin_path}" >/dev/null
    else
        compile_source "${source_path}" "${output_path}" "${cxx}"
    fi
}
