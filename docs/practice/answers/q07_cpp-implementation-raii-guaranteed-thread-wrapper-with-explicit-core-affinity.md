# Q7 Answer: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

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
