# Q6: C++ Implementation: Monotonic Arena Memory Allocator

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

In a high-rate tracking loop, frequent calls to malloc/free or new/delete invoke heap fragmentation and non-deterministic OS kernel locking delays. Write a production-grade, thread-safe MonotonicArena class in modern C++ that pre-allocates a contiguous memory byte block and resolves all subsequent allocation requests via a static bump pointer pointer update.

## Runtime Engineer Framing

Treat this as a user-space allocation policy for predictable latency. The goal is not to implement a general heap or understand DRAM internals; it is to reserve a known memory region, hand out aligned slices cheaply, define reset/lifetime semantics, and make thread-safety tradeoffs explicit.
