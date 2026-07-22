# Q1: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

As an edge-AI runtime engineer, explain false sharing from the perspective of user-space C++ code you can actually change. You do not need to describe DRAM internals or design a cache-coherence protocol.

Given two runtime threads that update different fields in nearby memory, explain:

- What false sharing is at a practical level.
- Why correct atomics or locks can still perform badly.
- How false sharing can degrade a low-latency 500Hz robot control loop.
- What code-level mitigations you can use in data layout, allocation, and thread-local ownership.
- How C++17/C++20 alignment tools such as `alignas` or `std::hardware_destructive_interference_size` can help, without treating them as the only acceptable fix.

## General Core Question

Two worker threads repeatedly update two different counters in a shared struct. The counters are logically independent, no data race exists, and each counter is updated with atomics or proper synchronization. Even so, performance collapses when the threads run on different CPU cores.

Explain a likely runtime-visible memory-layout cause. In your answer, cover:

- Why independent variables can still interfere with each other.
- What a cache line is and why writes affect the whole cache line rather than only one variable.
- How this differs from a data race.
- Two practical ways to redesign the data layout or ownership model to reduce the problem, without relying on any one C++ standard-library constant.
