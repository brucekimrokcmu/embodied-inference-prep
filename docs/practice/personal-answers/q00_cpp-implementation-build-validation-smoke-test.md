<!-- Personal practice copy. Source: docs/practice/questions/q00_cpp-implementation-build-validation-smoke-test.md -->

# Q0: C++ Implementation: Build Validation Smoke Test

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Create the smallest possible C++20 function and test that proves the repository's CMake build and test pipeline works.

Requirements:

- Add a function that can be compiled without external dependencies.
- Add a test executable that validates the function.
- Register the test with CTest.
- Keep the example simple enough to debug build-system failures separately from algorithmic failures.

## My Answer

_Write your answer here._

```cpp
# include <cassert>

constexpr int Add(const int& lhs, const int& rhs) noexcept {
    return lhs + rhs;
}

int main() {
    static_assert(Add(2, 3) == 5);
    assert(Add(-4, 10) == 6);
    return 0;
}

```


```
my_workspace/
├── CmakeLists.txt
├── main.cpp
└── build/
```

```
cmake_minimum_required(VERSION 3.14)
project(SimpleAddTest LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

enable_testing()

add_executable(add_test main.cpp)
add_test(NAME RunAddTest COMMAND add_test)
```

```
cmake -B build -S .
cmake --build build
```

## My Comments

- 

## Scoring Rubric

Use 1 to 5 per category (1 = weak, 5 = excellent).

| Category | Interviewer Scoring (1-5) | Agentic-AI Scoring (1-5) | Self Scoring (1-5) |
|---|---:|---:|---:|
| Correctness |  |  |  |
| Depth |  |  |  |
| Systems Rigor |  |  |  |
| Latency and Performance Awareness |  |  |  |
| Clarity and Structure |  |  |  |

### Totals

| Total Type | Interviewer | Agentic-AI | Self |
|---|---:|---:|---:|
| Total Score (/25) |  |  |  |

### Gap Notes

- 
