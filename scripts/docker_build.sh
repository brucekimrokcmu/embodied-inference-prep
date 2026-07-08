#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_name="${IMAGE_NAME:-embodied-inference-prep:latest}"

docker build \
    --file "${repo_root}/docker/Dockerfile" \
    --tag "${image_name}" \
    "${repo_root}"
