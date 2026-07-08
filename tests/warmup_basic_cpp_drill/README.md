# Warm-Up Validation Tests

`scripts/run_warmup.sh` looks here for per-question validation tests. Every warm-up question from `q01` through `q58` has a matching validator.

- `qNN_test.sh` receives: source path, output path, compiler, stdin path.
- `qNN_test.cpp` is compiled with the student's source pre-included.
- Comment-only source files still report `unimplemented` before validation.
- Shell validators are used for output checks, concept checks, and open-ended prompts.
- C++ validators are used for stable function/class contracts.

This keeps every warm-up question runnable while allowing stricter checks for prompts with stable names and lighter checks for explanation-oriented prompts.
