# Embodied Inference Prep

## Build Validation

Question 0 is a minimal C++20 smoke test used to validate the repository build.

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

Or use the helper scripts:

```sh
./scripts/configure.sh
./scripts/build.sh
./scripts/test.sh
```

Set `BUILD_DIR` to override the default `build` directory:

```sh
BUILD_DIR=/tmp/embodied-inference-build ./scripts/test.sh
```

The Q0 practice prompt, hint, and answer are indexed from `docs/practice/README.md`.

For role-specific interview preparation, use the L4/L5 on-device AI inference and robotics runtime question bank at `docs/l4_l5_on_device_ai_robotics_interview_questions.md`.

## Docker

Build the Docker image:

```sh
./scripts/docker_build.sh
```

Run the project tests inside the image:

```sh
./scripts/docker_test.sh
```

Enter the image with the repository root mounted into the container:

```sh
./scripts/docker_run.sh
```

By default this opens `bash` at `/workspace/embodied-inference-prep`.

Pass a command to run something non-interactively:

```sh
./scripts/docker_run.sh ./scripts/build.sh
./scripts/docker_run.sh ./scripts/test.sh
```

Set `IMAGE_NAME` to override the default image tag:

```sh
IMAGE_NAME=embodied-inference-prep:dev ./scripts/docker_build.sh
IMAGE_NAME=embodied-inference-prep:dev ./scripts/docker_test.sh
```
