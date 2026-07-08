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
