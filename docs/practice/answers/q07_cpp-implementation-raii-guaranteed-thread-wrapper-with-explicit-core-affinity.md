# Q7 Answer: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

The runtime-level requirement is safe worker lifetime. A wrapper should start a worker, request stop on destruction, and join automatically. `std::jthread` is a good base because it already joins in its destructor and passes a `std::stop_token` to cooperative tasks.

Affinity belongs in the wrapper as a best-effort or explicitly checked policy. On Linux, setting affinity through a native handle is platform-specific and can fail because of permissions, invalid CPU IDs, cgroup limits, or scheduling policy. A robust wrapper reports that failure instead of silently assuming isolation.

The payload should be written so it can observe cancellation, avoid unbounded blocking, and clean up user-space resources. Core pinning can reduce jitter, but it does not replace correct queue design, bounded allocation, priority management, or watchdog handling.

```cpp
#include <thread>
#include <pthread.h>
#include <functional>
#include <stdexcept>
#include <iostream>

class RealTimeWorker {
public:
    RealTimeWorker(int target_cpu_core, std::function<void(const std::stop_token&)> task_payload) {
        worker_thread_ = std::jthread([target_cpu_core, task_payload](std::stop_token st) {
            cpu_set_t cpuset;
            CPU_ZERO(&cpuset);
            CPU_SET(target_cpu_core, &cpuset);

            pthread_t current_handle = ::pthread_self();
            int result = ::pthread_setaffinity_np(current_handle, sizeof(cpu_set_t), &cpuset);
            if (result != 0) {
                std::cerr << "Warning: Failed to apply thread core affinity constraints.\n";
            }

            // Execute the primary task payload
            task_payload(st);
        });
    }

private:
    std::jthread worker_thread_;
};

```
