# Q0 Answer: C++ Implementation: Build Validation Smoke Test

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

The repository includes a minimal header-only function in `src/month0_core_cpp/include/q0_example.h`:

```cpp
constexpr int AddForBuildValidation(int lhs, int rhs) noexcept {
    return lhs + rhs;
}
```

The matching test lives in `tests/month0_tests/test_q0_example.cpp` and uses `static_assert` plus runtime `assert` checks.

Build and run it with:

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```
