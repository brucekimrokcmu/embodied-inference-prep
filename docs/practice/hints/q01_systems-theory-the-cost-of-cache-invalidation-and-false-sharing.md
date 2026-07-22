# Q1 Hint: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Hint

**Runtime-Level False Sharing:** Think about what your C++ runtime code controls: object layout, allocation patterns, per-thread state, and which thread writes which fields. Cache lines are the useful abstraction here, not DRAM cell behavior. If two threads modify different variables residing on the same cache line, the hardware coherence machinery can still force expensive ownership transfers.

Do not start from the C++17 constant. Start from the runtime symptom: two independently synchronized variables are close enough in memory to share a cache line. Then think about layout fixes such as padding/alignment, separating hot per-thread state into different objects, using thread-local counters, or aggregating per-thread values after the hot loop. `std::hardware_destructive_interference_size` is one tool, not the whole answer.
