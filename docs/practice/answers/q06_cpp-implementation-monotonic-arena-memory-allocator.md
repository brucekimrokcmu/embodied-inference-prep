# Q6 Answer: C++ Implementation: Monotonic Arena Memory Allocator

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

For a runtime engineer, the arena is a deterministic allocation strategy. Allocate a byte buffer up front, track an offset, align each request, and return a pointer if the request fits. Individual deallocation is intentionally unsupported; memory is reclaimed by resetting the arena at a safe phase boundary.

The important correctness points are:

- Align returned addresses for the requested type or alignment.
- Check overflow before advancing the offset.
- Define ownership: the arena owns the backing memory, callers borrow slices.
- Decide whether one arena is shared behind a lock/atomic offset or each runtime thread gets its own arena.
- Ensure `Reset` is only called when no outstanding objects from the arena are still in use.

This reduces latency jitter from general-purpose heap behavior, but it trades away flexible object lifetimes. It is a good fit for per-frame scratch buffers, temporary tensor metadata, and other phase-scoped allocations.

```cpp
#include <cstddef>
#include <memory>
#include <mutex>
#include <stdexcept>

class MonotonicArena {
public:
    explicit MonotonicArena(size_t total_capacity) : capacity_(total_capacity) {
        buffer_start_ = std::make_unique<char[]>(capacity_);
        current_ptr_ = buffer_start_.get();
    }

    void* Allocate(size_t size, size_t alignment) {
        std::lock_guard<std::mutex> lock(mutex_);
        void* ptr = current_ptr_;
        size_t space = capacity_ - (current_ptr_ - buffer_start_.get());

        if (std::align(alignment, size, ptr, space)) {
            current_ptr_ = static_cast<char*>(ptr) + size;
            return ptr;
        }
        throw std::bad_alloc(); // Arena allocation capacity exceeded
    }

    void Reset() noexcept {
        std::lock_guard<std::mutex> lock(mutex_);
        current_ptr_ = buffer_start_.get();
    }

    // Disable copy mechanics to maintain strict pointer integrity
    MonotonicArena(const MonotonicArena&) = delete;
    MonotonicArena& operator=(const MonotonicArena&) = delete;

private:
    std::mutex mutex_;
    size_t capacity_;
    std::unique_ptr<char[]> buffer_start_;
    char* current_ptr_;
};

```
