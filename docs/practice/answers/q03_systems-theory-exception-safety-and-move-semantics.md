# Q3 Answer: Systems Theory: Exception Safety and Move Semantics

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

For an edge runtime, a tensor buffer wrapper is usually an ownership type. It may own a heap block, mapped region, file descriptor, or accelerator-side handle. Moving the wrapper should transfer ownership; copying may duplicate ownership accidentally or be disabled entirely.

`std::vector` reallocates when it grows. During reallocation it must move or copy existing elements into new storage. If a custom move constructor is not marked `noexcept`, the container may avoid moving and prefer copying when copying exists, because that can preserve strong exception safety. For resource-owning runtime objects, that can be slow, incorrect, or impossible.

The practical rule is: if a type is just transferring handles and pointers, its move constructor and move assignment should usually be `noexcept`. The moved-from object should be left in a harmless empty state, such as a null pointer or invalid file descriptor. That lets containers reorganize storage without surprise allocation failures, duplicated handles, or latency spikes.

When a standard container like std::vector undergoes a reallocation sequence (e.g., during a size adjustment), it must shift its internal elements to a newly allocated, larger memory region. If the underlying data type provides a move constructor marked noexcept, the container will use std::move to transfer elements efficiently via fast pointer reassignments. However, if the move constructor lacks the noexcept specifier, the container defaults to using the copy constructor instead.
This fallback is an explicit design choice to preserve the Strong Exception Guarantee (the assurance that an operation either completes successfully or leaves the system state completely unchanged). If the container were to use a throwing move constructor and an exception occurred midway through transferring elements, the original vector would be left partially altered, making recovery impossible. For large on-device tensor buffers, falling back to copy operations introduces significant allocation overhead, deep memory duplication, and unpredictable latency spikes.
```cpp
class TensorBuffer {
public:
    TensorBuffer(TensorBuffer&& other) noexcept
        : data_(other.data_), size_(other.size_) {
        other.data_ = nullptr;
        other.size_ = 0;
    }

    TensorBuffer& operator=(TensorBuffer&& other) noexcept {
        if (this != &other) {
            delete[] data_;
            data_ = other.data_;
            size_ = other.size_;
            other.data_ = nullptr;
            other.size_ = 0;
        }
        return *this;
    }
private:
    float* data_ = nullptr;
    size_t size_ = 0;
};

```
