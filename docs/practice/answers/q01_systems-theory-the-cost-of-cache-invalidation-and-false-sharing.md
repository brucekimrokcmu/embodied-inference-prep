# Q1 Answer: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

The MESI protocol manages cache consistency across CPU cores via four distinct states: Modified, Exclusive, Shared, and Invalid.
False sharing occurs when two independent threads executing on separate CPU cores concurrently modify distinct variables that happen to occupy the same physical cache line (typically 64 bytes wide). When Core 1 modifies variable A, the cache hardware marks the entire cache line as Modified and forces an Invalid broadcast to all other cores sharing that line. When Core 2 attempts to write to variable B on that same cache line, it encounters a cache miss, stalls execution while fetching the updated line from main memory, and repeats the cycle.
In a 500Hz robot control loop, every millisecond counts (budget = 2ms). If a thread logging sensor values and a thread issuing motor commands experience false sharing, cache line thrashing can increase latency from nanoseconds to microseconds, causing missed deadlines and physical system instability.
Modern C++ provides std::hardware_destructive_interference_size (defined in <new>), which allows engineers to enforce structural alignment boundaries:
```cpp
#include <new>
struct alignas(std::hardware_destructive_interference_size) RealTimeSensorData {
    uint64_t timestamp;
    double joint_positions[7];
};

struct alignas(std::hardware_destructive_interference_size) MotorCommandData {
    double target_torques[7];
};

```

## General Core Answer

The likely cause is false sharing. CPUs usually move memory between cache and cores in cache-line-sized chunks, not in individual C++ object-sized chunks. A common cache line size is 64 bytes. If two counters sit near each other in the same struct, they may occupy the same cache line even though they are separate variables.

When one core writes to its counter, the coherence protocol treats the whole cache line as modified by that core. If another core wants to write a different counter on the same line, it must obtain ownership of that same line. The line bounces between cores, causing repeated invalidation and refetch traffic. The variables are logically independent, but the hardware coherence unit is shared.

This is different from a data race. A data race means two threads access the same memory location concurrently, at least one access is a write, and there is no valid synchronization. False sharing can happen even when there is no data race: each thread may update a different atomic counter correctly, but both counters still live on the same cache line.

Practical fixes include:

- Put heavily written per-thread counters into separate cache lines with padding or explicit alignment.
- Store per-thread state in separate objects or arrays indexed by thread, then combine results after the hot loop.
- Separate frequently written fields from read-mostly fields so unrelated writes do not invalidate data other cores need.
- Avoid placing hot counters next to each other in compact shared structs when different cores update them independently.
