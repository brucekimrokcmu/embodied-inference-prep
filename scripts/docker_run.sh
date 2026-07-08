#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_name="${IMAGE_NAME:-embodied-inference-prep:latest}"
container_workdir="/workspace/embodied-inference-prep"
build_dir="${BUILD_DIR:-${container_workdir}/build-docker-mounted}"

if [ "$#" -eq 0 ]; then
    set -- bash
fi

docker run --rm -it \
    --workdir "${container_workdir}" \
    --env "BUILD_DIR=${build_dir}" \
    --volume "${repo_root}:${container_workdir}" \
    "${image_name}" \
    "$@"
