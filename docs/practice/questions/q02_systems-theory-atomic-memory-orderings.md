# Q2: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

A real-time thread reads state vectors from a lock-free queue using std::memory_order_relaxed, while a background inference worker pushes updates using std::memory_order_relaxed. Explain why this code might crash or read stale pointers on an ARM-based robotics SoC, and describe the exact combination of memory_order flags required to establish a proper values-release relationship.
