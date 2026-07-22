# Q23 Hint: Systems Theory: Deterministic Stabilization and Memory Fragmentation

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

Fragmentation comes from allocation/free patterns with different sizes and lifetimes. Static planning works when tensor sizes and lifetimes are known. Dynamic shapes require buckets, re-planning, over-reservation, arenas, or page-style allocators.

**Fragmentation & Dynamic Inputs:** Continuous allocation calls of variable sizes create holes in the heap memory layout over time. To avoid this risk on robots, pre-allocate a single large buffer matching the largest possible model configuration.
