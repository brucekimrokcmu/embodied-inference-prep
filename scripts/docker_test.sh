#!/usr/bin/env bash
set -euo pipefail

image_name="${IMAGE_NAME:-embodied-inference-prep:latest}"

docker run --rm "${image_name}"
