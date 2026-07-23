# Physical Intelligence Hint Set: Candidate-Calibrated Runtime Loop

**Section:** Company-Specific Runtime Systems Interviews  
**Calibration:** IC4/L4 with L5 signal

Use these hints progressively. They are tuned to the recruiter-recommended loop: C++ systems and memory, deterministic profiling, hands-on SPSC coding, and cross-functional research/runtime negotiation.

## Hint 1: Weight Manager and Native Handles

1. Treat FDs, mapped addresses, accelerator handles, and framework model objects as different resources with different owners.
2. Use move-only RAII wrappers for unique native handles; use borrowed views only when lifetime is externally guaranteed.
3. Hot-swap should publish a complete immutable model context, not mutate objects that inference workers are actively reading.
4. Teardown must wait for in-flight inference or use generation-counted contexts/fences before closing FDs or unmapping memory.
5. The control path should never load models, allocate buffers, block on teardown, or wait for a loader thread.

## Hint 2: DMABUF and Cache Coherency

1. Zero-copy is a lifetime and synchronization design, not just "pass an FD around."
2. Separate CPU virtual address, FD, device import handle, and physical/device address concepts.
3. Cache sync is needed at ownership boundaries when CPU and device caches are not coherent or when the API contract requires it.
4. Pass slot ids or buffer handles through bounded queues; keep image payloads out of the message path.
5. Validate zero-copy with copy counts, cache-maintenance cost, bandwidth counters, corruption checks, and end-to-end latency distributions.

## Hint 3: NPU Latency Spike Profiling

1. Put timestamps around enqueue, runtime/delegate execution, synchronization, dequeue, and action publish.
2. Look for frequency/power-state transitions, thermal throttling, scheduler wakeup gaps, page faults, memory pressure, and IRQ/softirq bursts before blaming model math.
3. Compare known-good and bad OS images with the same model, inputs, clocks, thermal state, and runtime build.
4. Use ftrace/eBPF for scheduler and kernel events, `perf` for CPU cost, platform telemetry for power/frequency, and accelerator profilers for device-side stalls.
5. A production fix needs a rollout gate: p95/p99/p99.9 latency, spike rate, thermal-soak behavior, and trace evidence.

## Hint 4: 100 Hz Control Jitter

1. Measure wakeup-to-run separately from run duration; they imply different root causes.
2. Mutex contention shows blocking stacks or futex waits; scheduler delay shows a runnable RT thread not executing.
3. Page faults, allocator locks, log flushes, video encode, and network IRQs are common sources of rare spikes.
4. Use affinity, isolated cores, RT priority, preallocation, `mlockall`, cgroups, and IRQ placement only after measuring the current failure mode.
5. PREEMPT_RT reduces some scheduler latency but does not fix unbounded user-space work or bad lock design.

## Hint 5: SPSC Ring Buffer

1. SPSC can use one producer-owned write index and one consumer-owned read index.
2. Producer publishes data before updating the write index with `memory_order_release`.
3. Consumer reads the write index with `memory_order_acquire` before reading the slot.
4. Pad or align indices so producer and consumer do not bounce the same cache line.
5. Keep payload ownership outside the ring; pass descriptors, handles, or slot ids.

## Hint 6: Research Runtime Contract

1. Make hard constraints explicit: stale actions, actuator safety, p99 latency, thermal limits, and control-loop deadlines are not negotiable.
2. Offer tradeoffs with measurements: resolution, frame rate, frame history, quantization, static shapes, graph capture, preprocessing placement, and action rate.
3. Ask researchers for representative datasets and success metrics; provide platform traces and latency/thermal reports in return.
4. Staged rollout protects trust: offline replay, bench run, low-speed robot run, thermal soak, then full-speed evaluation.
5. L5 signal is turning conflict into a shared contract rather than saying yes or no based on opinion.

## Interviewer Nudge Prompts

1. "Who owns this FD at every point in the lifecycle?"
2. "What prevents this mapped address from outliving the buffer?"
3. "What trace would show the NPU is idle while the application is waiting?"
4. "How do you know the control thread was runnable but not scheduled?"
5. "Which atomic operation publishes the frame descriptor?"
6. "What metric would make the research model unsafe even if task success improved?"
7. "Which part of your answer is IC4 execution, and which part is L5 ownership?"
