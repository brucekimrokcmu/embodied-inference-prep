#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
warmup_dir="${repo_root}/src/warmup_basic_cpp_drill"
test_dir="${repo_root}/tests/warmup_basic_cpp_drill"
build_dir="${BUILD_DIR:-${repo_root}/build/warmup_basic_cpp_drill}"
cxx="${CXX:-c++}"
stdin_path="${WARMUP_STDIN:-/dev/null}"

usage() {
    cat <<'EOF'
Usage:
  scripts/run_warmup.sh [all|qNN|path/to/file.cpp ...]

Examples:
  scripts/run_warmup.sh
  scripts/run_warmup.sh all
  scripts/run_warmup.sh q01
  scripts/run_warmup.sh q01 q02
  scripts/run_warmup.sh src/warmup_basic_cpp_drill/q01_hello_cpp.cpp

Comment-only stubs emit "unimplemented".
Implemented files are validated with a matching test when one exists.
Files without matching tests are compiled, or compiled and run if they define main.
Executables read from /dev/null by default. Set WARMUP_STDIN to provide input.
EOF
}

resolve_target() {
    local target="$1"

    if [[ "${target}" == "all" ]]; then
        find "${warmup_dir}" -maxdepth 1 -type f -name 'q*.cpp' | sort
        return
    fi

    if [[ "${target}" =~ ^q[0-9][0-9]$ ]]; then
        find "${warmup_dir}" -maxdepth 1 -type f -name "${target}_*.cpp" | sort
        return
    fi

    if [[ -f "${target}" ]]; then
        printf '%s\n' "${target}"
        return
    fi

    if [[ -f "${repo_root}/${target}" ]]; then
        printf '%s\n' "${repo_root}/${target}"
        return
    fi

    printf 'unknown warm-up target: %s\n' "${target}" >&2
    return 1
}

is_unimplemented() {
    local source="$1"
    ! awk '
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\/\// { next }
        { found = 1 }
        END { exit found ? 0 : 1 }
    ' "${source}"
}

has_main() {
    local source="$1"
    local pattern='(^|[[:space:]])int[[:space:]]+main[[:space:]]*\('

    if command -v rg >/dev/null 2>&1; then
        rg -q "${pattern}" "${source}"
    else
        grep -Eq "${pattern}" "${source}"
    fi
}

run_source() {
    local source="$1"
    local name
    local question_id
    local output
    local test_cpp
    local test_sh

    name="$(basename "${source}" .cpp)"
    question_id="${name%%_*}"

    if is_unimplemented "${source}"; then
        printf '%s: unimplemented\n' "${name}"
        return
    fi

    mkdir -p "${build_dir}"
    output="${build_dir}/${name}.$$"
    test_cpp="${test_dir}/${question_id}_test.cpp"
    test_sh="${test_dir}/${question_id}_test.sh"

    if [[ -x "${test_sh}" ]]; then
        printf '%s: validating\n' "${name}"
        "${test_sh}" "${source}" "${output}" "${cxx}" "${stdin_path}" || return
        printf '%s: ok\n' "${name}"
        return
    fi

    if [[ -f "${test_cpp}" ]]; then
        printf '%s: validating\n' "${name}"
        "${cxx}" -std=c++20 -Wall -Wextra -pedantic -include "${source}" "${test_cpp}" -o "${output}" || return
        "${output}" || return
        printf '%s: ok\n' "${name}"
        return
    fi

    if has_main "${source}"; then
        printf '%s: compiling\n' "${name}"
        "${cxx}" -std=c++20 -Wall -Wextra -pedantic "${source}" -o "${output}" || return

        printf '%s: running\n' "${name}"
        "${output}" < "${stdin_path}" || return
        return
    fi

    printf '%s: compiling\n' "${name}"
    "${cxx}" -std=c++20 -Wall -Wextra -pedantic -c "${source}" -o "${output}.o" || return
    printf '%s: ok\n' "${name}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

targets=("$@")
if [[ "${#targets[@]}" -eq 0 ]]; then
    targets=("all")
fi

failures=0

for target in "${targets[@]}"; do
    while IFS= read -r source; do
        [[ -n "${source}" ]] || continue
        if ! run_source "${source}"; then
            printf '%s: failed\n' "$(basename "${source}" .cpp)" >&2
            failures=$((failures + 1))
        fi
    done < <(resolve_target "${target}")
done

if [[ "${failures}" -ne 0 ]]; then
    printf 'warm-up validation failed: %d failure(s)\n' "${failures}" >&2
    exit 1
fi
