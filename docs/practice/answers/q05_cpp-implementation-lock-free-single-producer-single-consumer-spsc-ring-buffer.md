# Q5 Answer: C++ Implementation: Lock-Free Single-Producer Single-Consumer (SPSC) Ring Buffer

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

```cpp
#include <atomic>
#include <optional>
#include <new>
#include <vector>

template<typename T, size_t Capacity>
class LockFreeSPSCQueue {
    static_assert((Capacity & (Capacity - 1)) == 0, "Capacity must be a power of 2.");
public:
    LockFreeSPSCQueue() : head_(0), tail_(0) {}

    template<typename... Args>
    bool Emplace(Args&&... args) {
        const size_t current_tail = tail_.load(std::memory_order_relaxed);
        const size_t current_head = head_.load(std::memory_order_acquire);

        if ((current_tail - current_head) == Capacity) {
            return false; // Queue is completely full
        }

        new (&storage_[current_tail & BufferMask]) T(std::forward<Args>(args)...);
        tail_.store(current_tail + 1, std::memory_order_release);
        return true;
    }

    std::optional<T> Pop() {
        const size_t current_head = head_.load(std::memory_order_relaxed);
        const size_t current_tail = tail_.load(std::memory_order_acquire);

        if (current_head == current_tail) {
            return std::nullopt; // Queue is completely empty
        }

        T* element_ptr = reinterpret_cast<T*>(&storage_[current_head & BufferMask]);
        std::optional<T> result(std::move(*element_ptr));
        element_ptr->~T();

        head_.store(current_head + 1, std::memory_order_release);
        return result;
    }

private:
    static constexpr size_t BufferMask = Capacity - 1;

    // Apply explicit padding alignment to isolate variables into separate cache lines
    alignas(std::hardware_destructive_interference_size) std::atomic<size_t> head_;
    alignas(std::hardware_destructive_interference_size) std::atomic<size_t> tail_;

    alignas(alignof(T)) typename std::aligned_storage<sizeof(T), alignof(T)>::type storage_[Capacity];
};

```
