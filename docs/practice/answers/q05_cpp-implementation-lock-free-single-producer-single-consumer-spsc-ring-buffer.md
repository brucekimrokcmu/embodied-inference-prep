# Q5 Answer: C++ Implementation: Lock-Free Single-Producer Single-Consumer (SPSC) Ring Buffer

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

A runtime-level SPSC ring buffer should keep the contract simple: one producer calls `Push`, one consumer calls `Pop`, capacity is fixed, and storage is allocated before the hot loop. The producer owns writes to the head index. The consumer owns writes to the tail index. This ownership model is what makes the queue simpler than MPMC.

The producer writes the item into the current head slot, then publishes the new head with release ordering. The consumer observes head with acquire ordering before reading the slot. In the other direction, the consumer publishes tail with release ordering after it consumes an item, and the producer observes tail with acquire ordering before deciding whether space is available.

Cache behavior still matters in user-space code. If `head` and `tail` are on the same cache line, producer and consumer may false-share the indices. Padding or aligning the index fields is a practical mitigation. The important runtime properties are bounded memory, no allocations in the hot path, clear single-writer ownership per index, and no blocking mutex in the frame path.

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
