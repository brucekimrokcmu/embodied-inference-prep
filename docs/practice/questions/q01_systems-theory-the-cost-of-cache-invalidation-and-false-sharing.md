# Q1: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Explain the mechanics of the MESI cache coherence protocol. Under what specific multi-threaded circumstances does false sharing occur, how does it degrade performance in a low-latency 500Hz robot control loop, and what C++17/C++20 feature completely neutralizes it?

## General Core Question

Two worker threads repeatedly update two different counters in a shared struct. The counters are logically independent, no data race exists, and each counter is updated with atomics or proper synchronization. Even so, performance collapses when the threads run on different CPU cores.

Explain a likely hardware-level cause. In your answer, cover:

- Why independent variables can still interfere with each other.
- What a cache line is and why writes affect the whole cache line rather than only one variable.
- How this differs from a data race.
- Two practical ways to redesign the data layout or ownership model to reduce the problem, without relying on any one C++ standard-library constant.
