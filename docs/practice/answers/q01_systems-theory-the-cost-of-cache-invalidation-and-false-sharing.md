# Q1 Answer: Systems Theory: The Cost of Cache Invalidation and false sharing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

At the level an edge-AI runtime engineer usually needs, false sharing is a data-layout problem: two threads write different variables, but those variables live on the same cache line. The program may be logically correct and free of data races, but the cache coherence machinery still has to move ownership of the line between cores.

MESI is useful background: cache lines can be Modified, Exclusive, Shared, or Invalid. You do not need to implement MESI, but you should understand the runtime consequence. If Core 1 writes variable A and Core 2 writes variable B on the same cache line, the whole line moves back and forth even though A and B are separate C++ objects.

In a 500Hz robot control loop, the budget is 2ms per cycle. If a telemetry/logging thread and a motor-command thread repeatedly write fields on the same cache line, coherence traffic can add latency jitter. That jitter matters more than average throughput because missed control deadlines can destabilize the system.

Runtime-level mitigations include:

- Separate hot write-heavy fields that are updated by different threads.
- Use per-thread state or thread-local counters, then aggregate after the hot loop.
- Add padding or alignment around heavily written fields.
- Split shared structs into ownership-oriented objects so each thread mostly writes memory it owns.
- Avoid placing unrelated atomics next to each other just because they are logically grouped.

Modern C++ provides `alignas` and `std::hardware_destructive_interference_size` (defined in `<new>`) as one way to express cache-line separation:
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
