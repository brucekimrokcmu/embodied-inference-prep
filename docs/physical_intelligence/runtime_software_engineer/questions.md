# Physical Intelligence Robotics Software Engineer: Candidate-Calibrated Loop

**Section:** Company-Specific Robotics Software Interviews  
**Calibration:** IC4/L4 with L5 signal  
**Format:** Four-module loop: systems design, profiling/debugging, practical C++, and cross-functional integration

## Interview Scenario

You are interviewing for a Robotics Software Engineer role focused on low-latency, real-time robot runtime infrastructure at Physical Intelligence. The team owns the production platform underneath learned policies: memory movement, sensor ingestion, model execution, control handoff, profiling, and reliability on real robots.

The recruiter expects the loop to validate both mid-level execution strength and senior-level trajectory. The interview should lean into the candidate's strongest evidence:

- DMABUF Heap zero-copy allocator work for Exynos NPU backends.
- C++ `weight_manager` thread managing FD/address-based model loading.
- LiteRT and ExecuTorch runtime experience.
- Android/Linux profiling of RSS/PSS, NPU latency, and OS power-state effects.
- Jetson/TensorRT robotics perception work.
- Cross-team negotiation experience around runtime constraints and model/compiler changes.

## Candidate Deliverables

1. Explain ownership, lifetime, and synchronization across C++ runtime objects, native handles, and accelerator buffers.
2. Debug rare latency spikes using evidence across application code, OS scheduler, memory, power state, driver, and accelerator layers.
3. Implement a bounded lock-free SPSC ring buffer for sensor-frame handoff.
4. Negotiate a production-safe model/runtime contract with researchers when model goals conflict with real-time robot constraints.

## Main Interview Questions

### Question 1: C++ Weight Manager and Native Handle Lifetime

You built or inherited a C++ `weight_manager` thread that loads model weights using a mix of file descriptors, mapped addresses, framework objects, and accelerator-visible buffers.

Design the ownership and shutdown model.

Be explicit about:

- Which object owns each FD, mapping, buffer handle, model instance, and compiled runtime object.
- How ownership is represented in C++: RAII wrappers, move-only types, shared ownership, borrowed views, and deleters.
- How the loader thread publishes a ready model to inference workers.
- How in-flight inference is drained or fenced before teardown.
- How you prevent dangling pointers, double-close, use-after-unmap, and races during model reload.
- Which operations are allowed on the real-time/control path and which are forbidden.
- What invariants you would assert or test.

Follow-up:

- When is `shared_ptr` the wrong answer for runtime objects?
- How do you handle reload when the old model is still serving actions?
- What telemetry would prove model loading is not perturbing inference latency?

### Question 2: DMABUF Heap, Zero-Copy, and Cache Coherency

Walk through the lifecycle of a camera or model buffer allocated from DMABUF Heap and consumed by CPU preprocessing plus GPU/NPU inference.

Be explicit about:

- Allocation, FD ownership, mapping, import/export, and release.
- CPU-visible address versus device-visible handle or IOVA.
- Cache coherency boundaries and when sync is needed.
- How you avoid extra copies while still keeping ownership clear.
- How you represent buffer state transitions across capture, preprocess, inference, and recycle.
- How you bound locking, allocation, and cache maintenance overhead.
- How you would debug stale data, torn frames, corruption, or unexplained latency from memory movement.

Follow-up:

- What changes between CPU-only, GPU, and NPU-backed paths?
- How do you compare zero-copy against a copy-based path fairly?
- What bugs appear only under thermal or high-bandwidth load?

### Question 3: Systemic Profiling of NPU Latency Spikes

During robot evaluation, NPU inference usually meets budget, but rare latency spikes appear only on one OS image. Model code and input shapes are unchanged. You suspect system image power-state behavior, scheduler latency, or driver/runtime interaction.

Design the debugging plan.

Be explicit about:

- First measurements and baseline conditions.
- Application timestamps around enqueue, delegate execution, synchronization, and dequeue.
- `perf`, ftrace/trace-cmd, eBPF, Android/Linux memory telemetry, power/frequency traces, and accelerator profiler signals.
- How you distinguish model/runtime cost from scheduler delay, page faults, memory pressure, IRQ/softirq interference, thermal throttling, and power-state toggling.
- How you minimize instrumentation overhead.
- What evidence would justify escalating to OS, driver, or vendor teams.
- How you turn the finding into a rollout gate.

Follow-up:

- What would point you away from model code and toward the OS image?
- How do you reproduce an intermittent p99 spike without relying on luck?
- What is the smallest trace schema you would require in production?

### Question 4: 100 Hz Control Loop Jitter Under Mixed Workloads

A 100 Hz control loop has a `10 ms` period and sees intermittent `15 ms` spikes while camera capture, inference, video streaming, and logging are active.

Walk through how you would isolate kernel preemption from application-level lock contention.

Be explicit about:

- Control-thread timing metrics: wakeup-to-run, run duration, command age, and deadline miss.
- Scheduler tracing, mutex/blocking analysis, context-switch analysis, page-fault counters, IRQ attribution, and CPU frequency.
- How you design stress tests for CPU, memory bandwidth, accelerator, network, and storage.
- How you use CPU affinity, IRQ affinity, cpusets/cgroups, memory locking, preallocation, and I/O containment.
- When PREEMPT_RT helps and when it does not.
- How you verify the fix with p95/p99/p99.9 evidence.

Follow-up:

- What evidence proves the control loop is blocked on a mutex?
- What evidence proves it is ready but not scheduled?
- What regressions would you watch after moving IRQs or changing RT priority?

### Question 5: Practical Coding - SPSC Sensor Frame Ring Buffer

Implement a bounded single-producer single-consumer ring buffer in C++17 or C++20 for passing sensor frame descriptors between a capture thread and an inference/preprocess thread.

Requirements:

- No dynamic allocation after construction.
- Single producer and single consumer only.
- `try_push` returns `false` when full.
- `try_pop` returns `false` when empty.
- Use correct acquire/release memory ordering.
- Avoid false sharing between producer and consumer indices.
- Store frame descriptors, not image payload copies.
- Include basic tests or usage examples.

Frame descriptor:

```cpp
struct FrameDesc {
  uint64_t seq;
  uint64_t capture_time_ns;
  uint32_t camera_id;
  int dma_buf_fd;
  uint32_t slot_id;
};
```

Follow-up:

- Why is SPSC simpler than MPMC?
- Where would you put cache-line padding?
- How would you add a "drop oldest" policy, and when is that policy wrong?

### Question 6: Research Runtime Negotiation

Researchers propose a higher-capacity policy that improves task success in offline evaluation but violates the robot's real-time frame budget. It needs more cameras, higher resolution, larger frame history, and more telemetry.

Define how you would negotiate the model/runtime contract without damaging trust.

Be explicit about:

- Latency, freshness, jitter, thermal, memory bandwidth, and safety budgets.
- Required profiling artifacts before robot rollout.
- Options such as quantization, pruning, lower resolution, lower action rate, weight sharing, static shapes, graph capture, GPU preprocessing, or staged rollout.
- How you separate hard safety constraints from negotiable quality/performance tradeoffs.
- How you present evidence to researchers, hardware, operations, and leadership.
- What pass/fail gates determine whether the policy can run on hardware.

Follow-up:

- What do you do if accuracy improves but p99 latency violates the safety envelope?
- How would you use the candidate's prior compiler/header negotiation experience here?
- What is the L4 answer versus the L5 answer?

## Interviewer Calibration

L4 pass:

- Gives clear ownership and lifetime rules for FDs, mappings, buffers, and model runtime objects.
- Separates real-time control from loading, allocation, logging, networking, and inference waits.
- Can implement a correct SPSC ring buffer with acquire/release semantics.
- Uses practical profiling tools and numeric gates.
- Communicates tradeoffs clearly to research and platform partners.

L5 signal:

- Connects C++ object lifetime to OS handles, accelerator fences, cache coherency, and model hot-swap behavior.
- Localizes p99 latency spikes across app, scheduler, memory, power, driver, and accelerator layers.
- Defines production trace schemas and rollout gates that operators and researchers can use.
- Negotiates architecture changes with evidence while preserving research velocity.

Major concern:

- Treats FDs, mapped pointers, and accelerator handles as interchangeable raw values.
- Uses unbounded queues or blocking calls on real-time paths.
- Optimizes average latency while ignoring freshness, jitter, p99, and stale outputs.
- Cannot explain acquire/release ordering in the SPSC coding task.
- Blames the model, OS, or driver without a falsifiable measurement plan.
