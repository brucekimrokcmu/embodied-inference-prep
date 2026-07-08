# Q6: C++ Implementation: Monotonic Arena Memory Allocator

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

In a high-rate tracking loop, frequent calls to malloc/free or new/delete invoke heap fragmentation and non-deterministic OS kernel locking delays. Write a production-grade, thread-safe MonotonicArena class in modern C++ that pre-allocates a contiguous memory byte block and resolves all subsequent allocation requests via a static bump pointer pointer update.
