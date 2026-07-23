# Physical Intelligence Sample Answers: Candidate-Calibrated Runtime Loop

**Section:** Company-Specific Runtime Systems Interviews  
**Calibration:** IC4/L4 with L5 signal

## Answer 1: C++ Weight Manager and Native Handle Lifetime

I would model model loading as a move-only resource graph. FDs, mappings, imported accelerator buffers, compiled model objects, and runtime contexts each need a single owner and a documented destruction order.

Example shape:

```cpp
class UniqueFd {
 public:
  explicit UniqueFd(int fd = -1) noexcept : fd_(fd) {}
  UniqueFd(const UniqueFd&) = delete;
  UniqueFd& operator=(const UniqueFd&) = delete;
  UniqueFd(UniqueFd&& other) noexcept : fd_(std::exchange(other.fd_, -1)) {}
  ~UniqueFd() { if (fd_ >= 0) close(fd_); }
  int get() const noexcept { return fd_; }

 private:
  int fd_;
};

struct ModelContext {
  UniqueFd weights_fd;
  MappedRegion weights_mapping;
  AcceleratorBuffer imported_weights;
  CompiledModel compiled_model;
  uint64_t generation;
};
```

The loader thread builds a complete `ModelContext` off the real-time path, runs validation/warmup, then publishes it atomically as an immutable generation. Inference workers take a short-lived reference to a ready context, execute, and release it. Model reload creates a new generation; the old generation is destroyed only after in-flight inference has drained or after a fence/refcount confirms no device work can touch its buffers.

I would avoid raw pointers across reload boundaries. `shared_ptr<const ModelContext>` can be acceptable for generation ownership, but I would not use shared ownership for every FD and buffer because it hides destruction order. Native handles should usually be move-only RAII members inside a higher-level context.

The control path never loads, maps, closes, compiles, waits on loader teardown, or allocates. It consumes only fresh validated outputs. Tests should cover double-close prevention, move semantics, reload during inference, failed partial load cleanup, teardown while workers are active, and latency during model swap.

## Answer 2: DMABUF Heap, Zero-Copy, and Cache Coherency

The DMABUF lifecycle is:

1. Allocate a buffer from DMABUF Heap and receive an FD.
2. Wrap the FD in a move-only owner.
3. Optionally map it into CPU address space for preprocessing or validation.
4. Import it into the GPU/NPU runtime to get a device-side handle.
5. Pass slot ids or buffer descriptors through the pipeline.
6. Synchronize ownership when CPU or device writes must become visible to the other side.
7. Recycle the slot only after downstream users and device work are complete.

I would keep these concepts separate: FD is a kernel object reference; CPU address is a mapping; device handle is the runtime import; IOVA/physical address is not a general userspace pointer. Confusing those leads to stale data, invalid access, or accidental copies.

For cache coherency, the answer depends on platform and API contract. If CPU writes the buffer before NPU reads it, the producer must perform the required sync/export operation before enqueue. If NPU writes output before CPU reads it, the consumer must sync/import or wait on the right fence before reading. The exact calls are platform-specific, but the invariant is not: ownership transfer must make the previous writer visible to the next reader.

To debug zero-copy, I would measure copy counts, cache sync time, buffer age, slot starvation, bandwidth, p95/p99 latency, and corruption signatures. A fair comparison against copy-based paths keeps model, inputs, clocks, thermal state, and queue policy constant.

## Answer 3: Systemic Profiling of NPU Latency Spikes

I would start with a paired experiment: same model, same input trace, same runtime build, same thermal setup, one known-good OS image and one suspect OS image.

Minimum application trace:

```text
capture_ts
preprocess_start/end
npu_enqueue
npu_device_start/end when available
npu_sync_wait_start/end
output_ready
action_publish
```

If app enqueue-to-sync is high but device execution is normal, I would inspect scheduler wait, runtime locks, memory pressure, and driver waits. If device execution itself stretches, I would inspect frequency, power state, thermal throttling, delegate behavior, and memory bandwidth.

Tools:

- ftrace/trace-cmd for sched wakeups, IRQs, softirqs, syscalls, and driver latency.
- eBPF probes for targeted runtime or kernel wait points.
- `perf` for CPU hotspots, context switches, cache misses, and lock-heavy code.
- RSS/PSS, page-fault, reclaim, and allocator telemetry for memory pressure.
- platform power/frequency traces for OS image power-state toggling.
- accelerator profiler/runtime logs for device queueing and execution.

Evidence pointing away from model code would include identical graph/input shapes, stable device kernel time, spikes aligned with frequency transitions or scheduler gaps, OS-image-specific behavior, and no spike under a controlled power/performance setting.

The rollout gate should include p95/p99/p99.9 inference latency after thermal soak, spike rate per hour, max action age, and a trace bundle attached to failures.

## Answer 4: 100 Hz Control Loop Jitter

I would split each control tick into wakeup-to-run and run duration.

If the thread wakes late or is runnable but not scheduled, I look at scheduler latency: RT priority, CPU isolation, IRQ/softirq load, CPU frequency, and higher-priority threads. If the thread starts on time but the tick takes too long, I look at application work: locks, allocation, page faults, logging, syscalls, or waits on inference/sensors.

Debug plan:

1. Add fixed trace events for timer expiry, thread wake, tick start, state read, command sample, actuator write, and tick end.
2. Use ftrace `sched_switch` and `sched_wakeup` to measure runnable delay.
3. Capture futex/mutex wait stacks to prove lock contention.
4. Track minor/major page faults, allocator calls, blocked I/O, and context switches.
5. Run stress tests for video encode, network transmit, NVMe logging, memory bandwidth, and accelerator load independently and together.

Mitigations should follow evidence: isolate the control core, pin `control_rt`, move unrelated IRQs away, preallocate and prefault memory, `mlockall`, move logging/video/network to lower-priority cgroups, and bound all queues. PREEMPT_RT is useful when measured scheduler latency dominates; it does not fix a mutex held by a logging thread or a control path that allocates.

Verification should compare before/after p95, p99, p99.9, max tick duration, wakeup-to-run latency, action age, and deadline misses under full production load plus margin.

## Answer 5: Practical Coding - SPSC Sensor Frame Ring Buffer

A strong implementation uses one producer-owned index and one consumer-owned index, with release/acquire at the publication boundary.

```cpp
template <typename T, size_t Capacity>
class SpscRing {
 public:
  static_assert(Capacity >= 2);

  bool try_push(const T& value) {
    const size_t write = write_.load(std::memory_order_relaxed);
    const size_t next = increment(write);
    if (next == read_.load(std::memory_order_acquire)) {
      return false;
    }
    slots_[write] = value;
    write_.store(next, std::memory_order_release);
    return true;
  }

  bool try_pop(T& out) {
    const size_t read = read_.load(std::memory_order_relaxed);
    if (read == write_.load(std::memory_order_acquire)) {
      return false;
    }
    out = slots_[read];
    read_.store(increment(read), std::memory_order_release);
    return true;
  }

 private:
  static constexpr size_t increment(size_t index) {
    return (index + 1) % Capacity;
  }

  std::array<T, Capacity> slots_{};
  alignas(64) std::atomic<size_t> write_{0};
  alignas(64) std::atomic<size_t> read_{0};
};
```

The producer writes the slot first, then publishes the new write index with release semantics. The consumer acquires the write index before reading the slot. The reverse applies when the consumer publishes that a slot has been freed.

The ring should store `FrameDesc` values or slot ids, not image payloads. If "drop oldest" is added, it must be explicit because it changes semantics: it is often right for camera frames where freshness matters, but wrong for ordered mode changes, calibration commands, or safety events.

## Answer 6: Research Runtime Negotiation

I would turn the conflict into a measured contract.

Hard constraints:

- Control-loop deadline and actuator safety cannot regress.
- Policy output must have a max age and valid-until time.
- p99 latency, thermal behavior, and fallback behavior must stay inside the robot safety envelope.

Negotiable variables:

- Camera count, resolution, frame rate, history length, pixel format, and sync tolerance.
- Quantization, pruning, static shapes, graph capture, batching strategy, GPU preprocessing, or action rate.
- Telemetry fidelity under overload.

I would ask researchers for representative datasets, offline success metrics, and acceptable degradation modes. Platform provides latency traces, memory bandwidth, thermal-soak results, failure cases, and suggested alternatives. For example: "The four-camera version improves offline success by 6%, but p99 action age crosses the safety limit after 18 minutes of thermal soak. A static-shape quantized version with shared weights preserves 5% improvement and keeps p99 under budget."

Rollout gates:

- Offline replay passes accuracy and safety checks.
- Bench runtime meets p95/p99 under full sensor/video/logging load.
- Thermal soak stays within latency and frequency limits.
- Low-speed robot trial has no deadline or stale-action regressions.
- Full-speed evaluation has rollback criteria and trace capture.

L4 signal is giving reasonable alternatives and measurements. L5 signal is building the shared contract, sequencing the rollout, and using evidence to preserve research velocity while defending safety.

## Scoring Rubric

L4 pass:

- Correctly models ownership of FDs, mappings, buffers, and model contexts.
- Can explain cache coherency and zero-copy tradeoffs without hand-waving.
- Designs a falsifiable profiling plan for OS/runtime latency spikes.
- Implements SPSC acquire/release semantics.
- Communicates model/runtime tradeoffs with numeric gates.

L5 pass:

- Handles hot-swap, in-flight work, fences, teardown order, and failure cleanup.
- Correlates traces across application, scheduler, memory, power, driver, and accelerator layers.
- Distinguishes safety constraints from negotiable research preferences.
- Creates rollout gates and postmortem artifacts useful to researchers, platform engineers, and operators.

No-hire / major concern:

- Uses raw FDs and pointers without ownership rules.
- Blocks real-time code on loading, logging, allocation, or inference.
- Cannot distinguish scheduler latency from lock contention.
- Writes an SPSC queue with data races or default sequential consistency without understanding the publication contract.
- Accepts a model that violates p99 safety limits because average latency or offline accuracy improved.
