# Q5: C++ Implementation: Lock-Free Single-Producer Single-Consumer (SPSC) Ring Buffer

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Implement a high-throughput, lock-free, single-producer single-consumer ring buffer in C++20 for a high-frequency camera frames collection stream. The circular buffer must avoid dynamic allocation during runtime, handle cache line boundary issues, and cleanly manage read/write sequence points using explicit atomic synchronization.

## Runtime Engineer Framing

Keep the implementation at the user-space queue boundary: one producer thread, one consumer thread, fixed capacity, no runtime allocation, predictable latency. Explain which index each thread owns, which index it observes from the other thread, and where acquire/release ordering is required.
