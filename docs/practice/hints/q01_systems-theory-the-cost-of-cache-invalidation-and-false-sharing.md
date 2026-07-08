# Q1 Hint: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**MESI & False Sharing:** Think about cache line alignment (typically 64 bytes). If two threads modify different variables residing on the same cache line, the underlying hardware must continuously broadcast invalidation messages, stalling execution. Look up alignas and std::hardware_destructive_interference_size.

For the general version, do not start from the C++17 constant. Start from the hardware unit of ownership: the cache line. Ask whether two independently synchronized variables are still close enough in memory to share the same line. Then think about layout fixes such as padding/alignment, separating hot per-thread state into different objects, or aggregating per-thread counters after the hot loop.
