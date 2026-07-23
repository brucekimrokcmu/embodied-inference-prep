# Embodied Inference Prep

## Workspace Layout

The repository is scoped to warmup C++ practice and Physical Intelligence interview preparation.

- `docs/README.md`: index for prompts, hints, answers, and project specs.
- `docs/warmup_cpp/`: warmup C++ questions, hints, answers, and personal answer file.
- `docs/physical_intelligence/`: Physical Intelligence runtime, controls, and toy-project preparation.
- `src/physical_intelligence/interview_stubs/`: empty C++ stubs for Physical Intelligence practice.
- `tests/warmup_cpp/`: validators for optional warmup C++ solution files.

## Build Validation

The CMake project is intentionally minimal after the cleanup. It validates that the workspace configures successfully.

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

Practice prompts, hints, and answers are indexed from `docs/README.md`.

## Warmup C++ Runner

Add warmup solution files under `src/warmup_cpp/` using names like `q01_hello_cpp.cpp`, then run:

```sh
./scripts/run_warmup.sh q01
./scripts/run_warmup.sh all
```

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
