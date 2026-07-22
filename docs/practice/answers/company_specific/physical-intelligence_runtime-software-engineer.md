# Physical Intelligence Sample Answers: Robotics Software Engineer

**Section:** Company-Specific Runtime Systems Interviews  
**Calibration:** Silicon Valley L4-L5 robotics platform/runtime engineer

## Answer 1: End-to-End Real-Time Architecture

I would split the robot into a hard real-time control path and best-effort producer paths:

- `control_rt`: 200 Hz, `SCHED_FIFO`, pinned to an isolated core. It reads actuator feedback, consumes the latest validated reference, runs safety checks, writes actuators, and appends compact telemetry to a preallocated ring.
- `sensor_capture`: camera and IMU ingest with hardware timestamps when available.
- `sync_worker`: forms camera/IMU bundles and drops late data.
- `preprocess_worker`: color conversion, resize, normalization, and tensor packing.
- `inference_worker`: GPU/NPU delegate execution.
- `action_bridge`: validates model output, applies stale-data policy, and publishes bounded references.
- `video_streamer`: encodes and sends operator/evaluation video.
- `logger`: drains telemetry/video asynchronously to storage.
- `supervisor`: owns fault state, recovery, rollback, and operator-visible status.

The control thread must not allocate, block on mutexes, wait on inference, read the network, encode video, flush logs, touch the filesystem, or perform unbounded queue operations. It should consume already prepared data using bounded SPSC queues or latest-value mailboxes.

Example cross-stage metadata:

```cpp
struct RuntimeStamp {
  uint64_t seq;
  uint64_t device_time_ns;
  uint64_t monotonic_time_ns;
  uint32_t source_id;
  uint32_t clock_domain;
};

struct ActionMsg {
  RuntimeStamp stamp;
  std::array<float, 7> target;
  uint32_t model_version;
  uint32_t status_flags;
};
```

If inference takes 80 ms, the control loop does not wait. It rejects stale actions at consume time and holds the last safe reference or executes a controlled stop. Logging uses a preallocated telemetry ring; a lower-priority writer drains it with drop counters when storage falls behind.

L4 signal: clear RT/non-RT separation.  
L5 signal: per-boundary ownership, timestamp contracts, CPU isolation, and degraded behavior are all explicit.

## Answer 2: Sensor Pipeline and Camera Synchronization

The capture path should preserve timing before optimizing image processing:

1. Camera drivers publish frame buffers with exposure or sensor timestamps. If only userspace timestamps are available, mark that clock domain explicitly because it includes dequeue and scheduler jitter.
2. Frames are stored in preallocated slots. Downstream stages pass slot ids or DMA handles, not frame copies.
3. The sync worker forms bundles `{cam0, cam1, imu_window}` using exposure timestamps and a max skew threshold, for example <= 2 ms for stereo-like perception.
4. Late or out-of-order frames are dropped before inference. The system should prefer a fresh incomplete stream over a complete stale bundle if the policy can tolerate missing inputs.
5. Each bundle carries frame ids, exposure timestamps, arrival timestamps, max skew, queue age, and drop counters.

For USB cameras, I would expect more host-side jitter and bus contention, so I would monitor kernel driver timestamps, USB errors, and IRQ placement carefully. For GMSL/CSI, I would push harder on hardware sync, device clock correlation, and zero-copy DMA paths.

Healthy-camera metrics:

- frame interval p50/p95/p99/max by camera.
- inter-camera skew histogram.
- capture-to-userspace dequeue latency.
- dropped, duplicated, corrupted, and late-frame counts.
- buffer occupancy and slot starvation.

Validation should include hardware strobes or visual timing patterns so synchronization is not judged only from application receive times.

## Answer 3: Actuator Control Path and Stale-Action Policy

The actuator loop consumes validated references, not raw model output.

Example action contract:

```cpp
enum class CommandKind : uint8_t {
  kContinuousSetpoint,
  kModeChange,
  kHold,
  kStop,
  kCalibration
};

struct CommandMsg {
  uint64_t seq;
  uint64_t publish_time_ns;
  uint64_t valid_until_ns;
  CommandKind kind;
  std::array<float, 7> target;
  float speed_scale;
  uint32_t source;
  uint32_t status_flags;
};
```

Continuous deltas or setpoints can use latest-value semantics because freshness matters more than preserving every intermediate value. Mode changes, calibration, gripper toggles, and safety commands need ordered delivery or explicit acknowledgment.

Consume rule:

```cpp
if (!latest || now_ns > latest->valid_until_ns || !SafetyGate(*latest)) {
  ExecuteHoldOrControlledStop();
} else {
  ExecuteBoundedReference(*latest);
}
```

One missed action: hold the current safe reference.  
Ten missed actions: remain stable and mark inference/action stream degraded.  
500 ms missing actions: enter controlled stop or operator-required degraded state.

Unsafe learned actions are rejected in the action bridge and again in the planner/safety gate before the servo sees them. Checks include NaN/Inf, workspace limits, joint limits, max delta per action, velocity/acceleration envelopes, collision envelopes when available, and stale timestamps.

## Answer 4: Linux Determinism Under Mixed Workloads

I would protect the control path first, then optimize throughput:

1. Run `control_rt` as `SCHED_FIFO` on an isolated core.
2. Pin video encoding, inference, logging, and networking workers to non-control cores.
3. Move unrelated IRQs away from the control core; place actuator-bus IRQs only after measuring wakeup latency and handler cost.
4. Preallocate and prefault real-time memory with `mlockall`; avoid dynamic allocation in steady-state RT code.
5. Use fixed-size telemetry rings and a lower-priority logger. Apply cgroup I/O weights/limits or `ionice` so NVMe flush spikes cannot starve control.
6. Bound network processing with IRQ/NAPI affinity and socket buffer sizing.
7. Consider PREEMPT_RT if scheduler latency is the measured problem, but do not use it as a substitute for bounded application work.

To prove the fix worked, run synthetic worst-case load: video encode, network transmit, inference, and disk logging at expected production rates plus margin. Gate on:

- control loop p99.9 duration < 5 ms.
- deadline miss rate < 0.1% or the team's chosen stricter SLO.
- max scheduler wakeup latency under threshold, for example < 500 us for `control_rt`.
- no major page faults in RT threads after startup.
- no increase in actuator command age during storage/network stress.

To distinguish failure modes:

- CPU starvation: high runnable time, high CPU utilization, `perf sched`/ftrace wakeup delays.
- scheduler latency: wakeup-to-run gaps despite available CPU.
- I/O stalls: blocked logger/writer tasks, flush spikes, dirty-page throttling, storage latency counters.
- IRQ interference: bursts of interrupt time or softirq time on the control core.

## Answer 5: Video Streaming and Packet Scheduling

The video path should be latency-bounded, not completeness-oriented.

Packet metadata:

```text
stream_id, frame_id, chunk_id, capture_ts_ns, encode_ts_ns,
send_ts_ns, deadline_ts_ns, keyframe/dependency flags
```

Transport tradeoff:

- WebRTC is strong when NAT traversal, congestion control, jitter buffers, and operational tooling matter.
- RTP/UDP is useful when the team wants lower-level control over pacing and packetization.
- TCP is usually a poor default for low-latency live video because head-of-line blocking can preserve old data at the cost of freshness.

Policy:

1. Pace packets with a token bucket or congestion controller to avoid burst queueing.
2. Prioritize control/status metadata and newest decodable video over old frame completion.
3. Keep reorder buffers shallow, for example 1 to 3 frames depending on frame rate and network jitter.
4. Drop late frames by deadline, not only by queue capacity.
5. Under overload, reduce bitrate/resolution first if visual detail matters; reduce frame rate first if every frame is expensive and temporal density is less important.

Video streaming must run on non-control cores with separate queues, bounded memory, and IRQ affinity that does not perturb `control_rt`.

Debug metrics: capture-to-encode latency, encode-to-send latency, inter-packet gap, receiver jitter, reorder depth, late-drop count, decode latency, displayed frame age, bitrate, packet loss, retransmission/FEC rate, and CPU time per stage.

## Answer 6: Profiling, Tracing, and Bottleneck Isolation

I would standardize a low-overhead trace event schema across the stack:

```cpp
struct TraceEvent {
  uint64_t t_ns;
  uint64_t seq;
  uint32_t robot_id;
  uint16_t stage;
  uint16_t event;
  uint32_t thread_id;
  uint32_t payload0;
  uint32_t payload1;
};
```

Required timestamps:

- camera exposure.
- driver/userspace dequeue.
- sync bundle publish.
- preprocess start/end.
- inference enqueue/start/end.
- action publish.
- planner accept/reject.
- servo consume.
- actuator write.
- logger enqueue/drop.
- network send/receive/display.

Tools:

- `perf` for CPU hotspots, cache misses, and thread-level cost.
- ftrace or `trace-cmd` for scheduler wakeups, IRQs, syscalls, and function latency.
- eBPF for targeted kernel/user latency probes with lower operational overhead.
- GPU/NPU profilers for delegate stalls, copies, synchronization, and kernel timing.
- packet captures for network jitter, loss, reordering, and pacing behavior.

The debugging loop is: reproduce under controlled synthetic load, collect correlated traces from all stages, identify the first stage where age or latency jumps, then change one variable. Evidence should precede kernel tuning or driver work.

Tracing overhead stays bounded with fixed-size ring buffers, binary events, sampling, trigger-on-deadline-miss snapshots, and per-run trace budgets.

## Answer 7: Reliability and Fault Recovery

I would use a state machine with explicit degraded modes:

- `NORMAL`: all pipelines meet freshness and latency contracts.
- `DEGRADED_SENSOR`: missing camera/depth/video data, but control can hold or run reduced capability.
- `DEGRADED_INFERENCE`: accelerator/model unavailable; run hold, scripted fallback, or CPU fallback at reduced rate.
- `DEGRADED_IO`: logging/storage/network behind; drop best-effort data and preserve control.
- `CONTROL_STOP`: controlled stop for prolonged stale commands or actuator-bus issues.
- `E_STOP`: severe actuator/sensor inconsistency, impossible encoder jump, hard safety violation, or unsafe command leakage.

Fault mapping:

- Camera frame timeout: degrade perception, increment drop counters, continue control if safe references remain.
- Sensor timestamp skew beyond threshold: reject bundle and degrade sensor pipeline.
- Actuator bus timeout: controlled stop or E-stop depending on severity and duration.
- Accelerator reset: immediately stop consuming model actions, notify recovery worker, continue hold/control fallback.
- Storage backpressure: drop/compress less telemetry, never block control.
- Network degradation: reduce bitrate/frame rate or drop video; never affect control.
- Encoder discontinuity: E-stop if physically impossible.

Recovery requires a healthy window, not one good sample. For example, re-enter normal only after camera skew, inference latency, actuator communication, and control timing stay within limits for several seconds. Operators should see a concise fault reason, timeline, last good command/action, queue ages, dropped data counts, and a trace bundle id for postmortem.

## Answer 8: Cross-Functional Performance Contract

I would turn the new policy request into an explicit resource and timing contract:

- camera contract: streams, resolution, frame rate, pixel format, timestamp source, sync tolerance.
- model input contract: required frames, max frame age, allowed missing inputs, preprocessing format.
- runtime budget: capture, sync, preprocess, inference, postprocess, planner, servo handoff.
- resource budget: CPU cores, GPU/NPU time, memory bandwidth, network bandwidth, storage bandwidth, thermal envelope.
- safety contract: max action delta, valid workspace, stale threshold, fallback behavior.
- observability contract: metrics and traces required for rollout.

Example budget:

```text
camera capture/dequeue p95 <= 4 ms
sync bundle p95 <= 2 ms
preprocess p95 <= 6 ms
inference p95 <= 24 ms
postprocess/safety p95 <= 3 ms
action publish p95 <= 1 ms
control consume/write p99 <= 5 ms period with no blocking
```

If the ideal model input contract conflicts with real-time safety, safety wins. Options include lower resolution, lower frame rate, fewer cameras, GPU preprocessing, quantized input, action-rate reduction, asynchronous policy updates, or staged rollout at reduced robot speed.

Rollout gates:

- control deadline miss rate within SLO under full sensor/video/logging load.
- inference p95/p99 within budget after thermal soak.
- camera skew and frame-age distributions within contract.
- network/video stress does not change control-loop latency distribution.
- storage backpressure causes telemetry drops, not control misses.
- safety intervention rate does not regress versus baseline.

## Scoring Rubric

L4 pass:

- Cleanly separates real-time control from sensor, inference, logging, video, network, and storage work.
- Uses bounded queues/mailboxes with timestamp and stale-data contracts.
- Knows practical Linux scheduling, affinity, memory, I/O, and tracing concepts.
- Designs latency-oriented camera and video drop policies.
- Provides measurable release gates.

L5 pass:

- Owns the whole performance budget across OS, drivers, middleware, accelerators, networking, storage, and application code.
- Can localize rare p99 latency spikes with correlated traces and minimal overhead.
- Distinguishes application fixes from kernel, driver, IRQ, DMA, or device-clock issues.
- Defines cross-team contracts researchers and operators can actually use.
- Designs graceful degradation, rollback, postmortem artifacts, and thermal/load validation.

No-hire / major concern:

- Allows blocking, allocation, logging flushes, inference waits, or unbounded queues in the control loop.
- Optimizes only average latency and ignores jitter, age, p99, drops, and deadline misses.
- Preserves old camera frames or stale actions because "no data loss" was prioritized over real-time correctness.
- Cannot explain how to use tracing/profiling evidence to isolate the bottleneck.
- Has no numeric gates for release or rollback.
