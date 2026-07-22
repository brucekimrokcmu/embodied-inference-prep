# Physical Intelligence Hint Set: Robotics Software Engineer

**Section:** Company-Specific Runtime Systems Interviews  
**Calibration:** L4-L5 robotics platform/runtime engineer

Use these hints progressively. They are tuned for a role focused on low-latency robotics systems, Linux performance, sensor pipelines, video streaming, and production debugging.

## Hint 1: End-to-End Runtime Architecture

1. Put the 200 Hz control loop at the center as the highest-priority deterministic consumer.
2. Camera capture, inference, video streaming, logging, compression, network I/O, and storage I/O should not run on the control thread.
3. Cross-thread messages need monotonic timestamp, hardware timestamp when available, sequence number, source id, validity/status, and payload age checks.
4. Use bounded queues or latest-value mailboxes. Unbounded queues convert transient overload into stale data.
5. Treat "freshest valid data" and "ordered reliable command" as different contracts.

## Hint 2: Sensor Pipeline and Synchronization

1. Prefer hardware timestamps close to exposure time; software timestamps after userspace dequeue include driver and scheduler jitter.
2. A synchronized camera bundle should include frame ids, exposure timestamps, arrival timestamps, clock domain, and max skew.
3. Use preallocated slots or DMA-backed buffers when possible; pass handles/slot ids instead of copying frames.
4. Under overload, drop late frames before they enter inference. A complete old frame is usually worse than a missing frame for real-time control.
5. Validate synchronization with external signals, GPIO strobes, PTP/device clock checks, or known visual timing patterns.

## Hint 3: Actuator Handoff and Stale Actions

1. Learned-policy outputs are suggestions, not actuator commands.
2. The actuator loop should consume only safety-gated references or hold commands.
3. Continuous deltas can use latest-value semantics; mode changes, calibration, and safety commands need ordering or acknowledgment.
4. One missed action can hold the previous safe reference; prolonged missing actions should enter degraded mode or controlled stop.
5. Stale rejection belongs at consume time because queueing and scheduling delays happen after publication.

## Hint 4: Linux Determinism

1. Isolate the control core, pin the control thread, and keep noisy work such as encoding/logging off that core.
2. Move device IRQs away from the control core unless the device is directly needed by the control loop and the latency is measured.
3. Preallocate and prefault memory; avoid page faults and allocator locks in real-time paths.
4. Drain telemetry through an async ring to a lower-priority writer; use cgroups or I/O priority to contain storage spikes.
5. PREEMPT_RT helps scheduler latency, but it does not fix bad locking, bad IRQ placement, slow drivers, or unbounded application work.

## Hint 5: Video Streaming and Networking

1. Design for latency-bounded streaming, not perfect delivery.
2. Packets should carry stream id, frame id, chunk id, capture timestamp, send timestamp, and deadline.
3. Use pacing to avoid burst-induced queueing; prioritize timing metadata and newest frames over old frame completion.
4. Reorder buffers should be shallow. Late frames should be dropped rather than displayed out of order.
5. Network streaming must be CPU, IRQ, and memory-bandwidth isolated from control-critical work.

## Hint 6: Profiling and Tracing

1. Add timestamps at capture, userspace dequeue, preprocess start/end, inference start/end, action publish, planner accept/reject, servo consume, and actuator write.
2. Track p50/p95/p99/max, queue depth, drops, deadline misses, page faults, context switches, IRQ time, CPU frequency, GPU/NPU time, and storage flush latency.
3. Use ftrace/eBPF for scheduler and syscall behavior, `perf` for CPU hotspots, GPU profilers for accelerator stalls, and packet captures for network jitter.
4. Correlate events with a shared monotonic clock or explicit clock-sync records.
5. Keep tracing bounded with ring buffers, sampling, trigger-on-threshold dumps, and fixed event schemas.

## Hint 7: Reliability and Recovery

1. Camera timeout and storage backpressure may degrade evaluation; actuator timeout or impossible encoder jump should stop the robot.
2. Accelerator failure should not block control. Switch to deterministic fallback and recover in a worker.
3. Recovery requires health checks over a window, not just one successful frame or inference.
4. Operators need a concise fault reason, timeline, dropped data counts, and a replayable trace bundle.
5. Rollback new pipelines when latency, thermal behavior, or safety intervention rate regresses beyond gates.

## Interviewer Nudge Prompts

1. "Which exact operation in your design has the longest worst-case latency?"
2. "Where do old camera frames get dropped?"
3. "How do you know a timestamp is exposure time and not userspace dequeue time?"
4. "What evidence would make you change IRQ affinity?"
5. "What happens to control if NVMe writes stall for 200 ms?"
6. "How do you prove video streaming is not causing missed control deadlines?"
7. "Which metric tells you the model is fast but the pipeline is still unsafe?"
