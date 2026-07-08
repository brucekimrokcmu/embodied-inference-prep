FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace/embodied-inference-prep

COPY . .

ENV BUILD_DIR=/workspace/embodied-inference-prep/build-docker

RUN ./scripts/test.sh

CMD ["./scripts/test.sh"]
