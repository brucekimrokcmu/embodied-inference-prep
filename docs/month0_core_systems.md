# Month 0: Core Systems Programming, Resource Stability, and DS/A

## Focus

Build production-grade C++17/C++20 systems foundations for edge runtime work: deterministic memory boundaries, cache-aware data layout, exception-safe resource ownership, and low-level concurrent execution.

## Core Outcomes

- Write C++ that is stable under long-running, resource-constrained execution.
- Understand when runtime allocation is unacceptable in real-time loops.
- Build primitives that resemble runtime internals: arenas, queues, and thread pools.
- Reason explicitly about cache lines, memory ordering, and object lifetimes.

## Resource Stability and Safety

Key areas:

- RAII design for hardware-adjacent resources.
- Custom ownership wrappers inspired by `unique_ptr` and `shared_ptr`.
- Move semantics using `std::move` and `std::forward`.
- Rule of 5 correctness for classes managing raw resources.
- Exception safety when allocation or initialization can fail.

Implementation targets:

- `src/month0_core_cpp/include/arena_allocator.h`
- `src/month0_core_cpp/src/arena_allocator.cpp`
- `src/common/types.h`

Suggested exercises:

- Implement a monotonic arena with fixed capacity.
- Add alignment-aware allocation.
- Reject allocations deterministically instead of falling back to heap allocation.
- Add reset semantics for frame-based or request-based reuse.

## Low-Level Concurrency and Cache Engineering

Key areas:

- Thread lifecycle management with `std::jthread`.
- Atomic synchronization using acquire and release ordering.
- Memory fences where producer/consumer visibility must be explicit.
- Lock-free circular queues using `std::atomic`.
- False-sharing prevention with `alignas` and cache-line padding.

Implementation targets:

- `src/month0_core_cpp/include/lock_free_queue.h`
- `src/month0_core_cpp/include/rt_thread_pool.h`
- `src/month0_core_cpp/src/rt_thread_pool.cpp`
- `tests/month0_tests/test_lock_free_queue.cpp`

Suggested exercises:

- Implement a single-producer/single-consumer ring buffer.
- Add bounded-capacity push/pop behavior.
- Validate behavior under concurrent producer and consumer threads.
- Pad hot atomic counters so independent cache lines are not invalidated unnecessarily.

## High-Performance Data Structures and Algorithms

Key areas:

- Cache-friendly sequential layouts.
- Contiguous vectors versus pointer-heavy node structures.
- Priority structures for latency-sensitive scheduling.
- Monotonic allocation to avoid `malloc` and `free` overhead during real-time loops.

Design notes:

- Prefer predictable memory access over abstraction-heavy structures in hot paths.
- Keep ownership and lifetime boundaries explicit.
- Treat allocation as part of runtime behavior, not just construction detail.

## Validation Checklist

- Arena allocation is bounded, aligned, and deterministic.
- Queue operations are lock-free for the selected producer/consumer model.
- Thread-pool shutdown is explicit and does not leak work or threads.
- Tests cover full queue, empty queue, wraparound, and concurrent access.
