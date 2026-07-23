#!/usr/bin/env bash

compile_source() {
    local source_path="$1"
    local output_path="$2"
    local cxx="$3"
    "${cxx}" -std=c++20 -Wall -Wextra -pedantic -c "${source_path}" -o "${output_path}.o"
}

search_source() {
    local pattern="$1"
    local source_path="$2"

    if command -v rg >/dev/null 2>&1; then
        rg -q "${pattern}" "${source_path}"
    else
        grep -Eq "${pattern}" "${source_path}"
    fi
}

require_pattern() {
    local source_path="$1"
    local pattern="$2"
    local description="$3"

    if ! search_source "${pattern}" "${source_path}"; then
        printf 'expected %s\n' "${description}" >&2
        exit 1
    fi
}

compile_if_no_main_otherwise_run() {
    local source_path="$1"
    local output_path="$2"
    local cxx="$3"
    local stdin_path="${4:-/dev/null}"

    if search_source '(^|[[:space:]])int[[:space:]]+main[[:space:]]*\(' "${source_path}"; then
        "${cxx}" -std=c++20 -Wall -Wextra -pedantic "${source_path}" -o "${output_path}"
        "${output_path}" < "${stdin_path}" >/dev/null
    else
        compile_source "${source_path}" "${output_path}" "${cxx}"
    fi
}
