#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

if git status >/dev/null 2>&1; then
    echo "Git already works in ${repo_root}."
    git status --short --branch
    exit 0
fi

if [ ! -d ".git-store" ]; then
    echo "Expected .git-store to exist, but it was not found." >&2
    exit 1
fi

if mountpoint -q .git; then
    echo "Unmounting read-only .git mountpoint."
    sudo umount .git
fi

if [ -e ".git" ]; then
    rmdir .git
fi

mv .git-store .git

git status --short --branch
