<!-- Personal practice copy. Source: docs/practice/questions/q01_systems-theory-the-cost-of-cache-invalidation-and-false-sharing.md -->

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

## My Answer

_Write your answer here._
The MESI protocol manages cache consistency across CPU cores via four distinct states: Modified, Exclusive, Shared, Invalid. False sharing can occur when two independent threads exeucitng on separate cores concurrently modifying distinct variables happen to occupy the same physical cache line. 

When Core 1 modified variable A, the cache hardware must mark the entire cache line as Modified and forces Invalid broadcast to all other cores sharing that line. (Core 2's cache line state becomes Invalid) When Core 2 attempts to write to a variable B on the same cache line, it encounters a cache miss. It stalls execution.
Core 2 then broadcasts  read-with-intent-to-modify request, Core 1 hears the request and changes its local state from Modified to Invalid. 
Core 2 then receives the updated cache line, merges its new line with updated variable B, and changes the state into Modified.

So the false sharing occurs because both cores try to update the same cache line, which is the smallest unit of data that can be transferred between cache and the main memory.

This could degrade the performance of a 500 Hz robot control loop (2ms).
For example, say there is a control loop invocation and telemetry logging occupy the same cache line.

```cpp
struct SystemMetrics{
    std::atomic<uint_64t> control_loop_invocations{0}; // written by core 0
    std::atomic<uint_64t> logging_bytes_written{0}; // written by core 1
};

global_ptr<SystemMetrics> metrics_;
```

As uint_64t occupies 8 bytes, and they are sequentially defined in the struct, both packs into a single 64-byte cache line.

Say, the math to compute the next trajectory takes 1850us, and you would safely have 150us headroom buffer to write to motors. However, core 1 receives an influx of data packets and writes into logging_byte_written. Core 1 issues Invalid for the entire cache line, so Core 0's local cache line state becomes invalid. After core 0 completes calculating the next trajectory line at 1850us, it will try to execute metrics->control_loop_invocations.fetch_add(1);

However, Core 0 will hit L1/L2 cache miss, its execution stalls, and drops down to L3 cache. Then core 0 now transitions state to Modified. The penaly is about 50~100 ns. Then Core 0 writes.
But then, Core 1 will process the next packet and again invalidates Core 0. 

This process will repeat thousands of times causing thousands of times 50~100ns delay, which would be about 200us, surpassing the 2ms window. The real-time kernel registers a deadline overrun (jitter). The motor driver doesn't receive its torque command inside its strict 2ms window, causing the actuator trajectory to stutter, which manifests as physical vibration or control instability on the robot arm.


In C++17/20, the dynamic memory management library <new> neutralizes false sharing. 
```cpp
#include <new>
#include <atomic>

struct SystemMetric {
    alignas(std::hardware_destructive_interference_size) std::atomic<uint_64t> control_loop_invocations{0};
    alignas(std::hardware_destructive_interference_size) std::atomic<uint_64t> logging_bytes_written{0};
```

This lets the compiler query the exact target architecture at compile-time to determine the maximum cache-line layout required to avoid interference. Compile needs to read from built-int tables via a careful flag management. 


## My Comments

- 

## Scoring Rubric

Use 1 to 5 per category (1 = weak, 5 = excellent).

| Category | Interviewer Scoring (1-5) | Agentic-AI Scoring (1-5) | Self Scoring (1-5) |
|---|---:|---:|---:|
| Correctness |  |  |  |
| Depth |  |  |  |
| Systems Rigor |  |  |  |
| Latency and Performance Awareness |  |  |  |
| Clarity and Structure |  |  |  |

### Totals

| Total Type | Interviewer | Agentic-AI | Self |
|---|---:|---:|---:|
| Total Score (/25) |  |  |  |

### Gap Notes

- 
