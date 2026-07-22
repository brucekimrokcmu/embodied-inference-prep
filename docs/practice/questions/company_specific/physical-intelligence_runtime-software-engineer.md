# Physical Intelligence Robotics Software Engineer: Real-Time Platform Runtime

**Section:** Company-Specific Runtime Systems Interviews  
**Calibration:** Silicon Valley L4-L5 robotics software engineer  
**Format:** 60-minute systems interview plus optional 30-minute deep dive

## Interview Scenario

You are joining the robotics software team for a Physical Intelligence-style robot platform. Researchers provide learned policies and task definitions, but your team owns the production runtime that makes cameras, sensors, networking, model execution, logging, and actuator control meet real-world latency and reliability requirements.

The prototype works in demos but misses deadlines under load. Camera frames occasionally bunch, logging causes disk stalls, inference jitter leaks into control decisions, and operators lack enough tracing to debug failures after a run. Your job is to redesign the platform runtime so the robot can run repeated manipulation evaluations safely and predictably.

Assume this platform:

- Robot control loop: 200 Hz, 5 ms period
- Learned-policy action rate: 10 to 20 Hz
- Cameras: 2 RGB cameras, `1280x720 @ 60 FPS`
- Optional depth camera: `640x480 @ 30 FPS`
- IMU: 1 kHz
- Actuator bus: command/feedback exchange every control tick
- Inference target: p95 <= 40 ms from synchronized camera bundle to action
- End-to-end target: p99 <= 15 ms from newest valid action availability to actuator write
- Network stream: operator/evaluation video over lossy Wi-Fi or Ethernet
- Logging: high-rate telemetry plus compressed video for offline debugging
- Hardware: Linux robot computer with CPU, GPU/NPU accelerator, NVMe storage, and multiple USB/GMSL/CSI cameras

Hard requirements:

- The 200 Hz control loop must not block on inference, cameras, networking, storage, allocation, or logging.
- Sensor data and learned actions must carry timestamps and freshness contracts.
- Unsafe, stale, malformed, or physically infeasible commands must be rejected before actuator write.
- Profiling and tracing must identify the cause of missed deadlines across OS, driver, middleware, network, and application layers.

## Candidate Deliverables

1. Thread/process architecture with scheduling priorities and CPU/core isolation strategy.
2. Sensor pipeline design, including timestamping, camera synchronization, buffering, and drop policy.
3. Actuator/control data path with deterministic command handoff and stale-data rejection.
4. Linux performance plan covering scheduling, memory, I/O, drivers, and kernel/runtime tuning.
5. Video streaming/networking plan for low jitter under packet loss or contention.
6. Profiling and observability plan using tools such as `perf`, ftrace, eBPF, GPU profilers, and packet captures.
7. Reliability state machine for sensor, accelerator, actuator, and storage faults.
8. Rollout gates with numeric pass/fail thresholds.

## Main Interview Questions

### Question 1: End-to-End Real-Time Architecture

Design the runtime architecture from sensor capture to actuator write.

Be explicit about:

- Which threads/processes exist and what each owns.
- Which threads run with real-time priority.
- CPU affinity and isolation strategy.
- Which queues/buffers exist between stages.
- What work is forbidden on the control thread.
- How timestamps and sequence numbers propagate across the system.

Follow-up:

- What changes if the inference worker sometimes takes 80 ms?
- How do you keep debug logging from perturbing the 5 ms control period?
- Where would you draw the boundary between middleware and custom runtime code?

### Question 2: Sensor Pipeline and Camera Synchronization

Design the camera/IMU ingestion pipeline for two `1280x720 @ 60 FPS` cameras and a 1 kHz IMU.

Be explicit about:

- Hardware timestamping vs software timestamping.
- Buffer ownership and zero-copy strategy.
- Frame synchronization tolerance.
- Backpressure and drop policy.
- Handling out-of-order, duplicated, corrupted, or late frames.
- How synchronized bundles are exposed to inference without blocking capture.

Follow-up:

- What metrics tell you camera timing is healthy?
- What would you change for GMSL/CSI cameras versus USB cameras?
- How do you verify synchronization without trusting application timestamps?

### Question 3: Actuator Control Path and Stale-Action Policy

Design the data path from learned-policy actions and operator commands into the 200 Hz actuator loop.

Be explicit about:

- Command/action message schema.
- SPSC or mailbox handoff semantics.
- Freshness thresholds.
- Mode changes versus continuous setpoints.
- Saturation and physical feasibility checks.
- Safe fallback when no fresh action is available.

Follow-up:

- Is "drop oldest" always correct for command queues?
- What does the servo loop do for one missed action, ten missed actions, and 500 ms of missing actions?
- Where are unsafe learned actions rejected?

### Question 4: Linux Determinism Under Mixed Workloads

The robot misses occasional 5 ms control deadlines when video encoding and logging spike CPU and disk I/O.

Propose a Linux-level mitigation plan.

Be explicit about:

- Scheduling policy and priority assignment.
- CPU isolation, IRQ affinity, and core pinning.
- Memory preallocation, page faults, and allocator policy.
- Storage I/O containment.
- Network IRQ/NAPI considerations.
- Kernel parameters or PREEMPT_RT tradeoffs.
- How to prove the fix worked.

Follow-up:

- Which problems require kernel/driver work rather than application changes?
- How would you distinguish CPU starvation from scheduler latency from I/O stalls?

### Question 5: Video Streaming and Packet Scheduling

The robot streams RGB video to a remote evaluator. Under network contention, frames arrive in bursts, jitter spikes to 45 ms, and old frames are sometimes displayed after newer ones.

Design a low-latency video transport strategy.

Be explicit about:

- Frame packetization and metadata.
- RTP/WebRTC/custom UDP/TCP tradeoffs.
- Pacing, congestion response, and prioritization.
- Reorder buffer size and late-frame policy.
- What gets dropped first under overload.
- How stream timing is observed and debugged.

Follow-up:

- When would you prefer lower resolution over lower frame rate?
- How do you prevent video streaming from harming control-loop determinism?

### Question 6: Profiling, Tracing, and Bottleneck Isolation

A robot run shows rare 30 ms latency spikes, but the logs only show that control was late.

Design a debugging plan.

Be explicit about:

- What timestamps you add at each stage.
- Which histograms and counters you collect.
- How you use `perf`, ftrace, eBPF, GPU profilers, and packet captures.
- How you correlate events across processes and machines.
- How you reproduce the issue under synthetic load.
- What evidence is required before changing code, kernel settings, or drivers.

Follow-up:

- What is the minimum trace event schema you would standardize across the robotics stack?
- How do you keep tracing overhead bounded?

### Question 7: Reliability and Fault Recovery

Design a runtime reliability model for production robot evaluations.

Include:

- Camera frame timeout.
- Sensor timestamp skew.
- Actuator bus timeout.
- Accelerator reset or delegate failure.
- Storage backpressure.
- Network degradation.
- Encoder discontinuity or physically impossible state jump.
- Recovery path and rollback behavior.

Follow-up:

- Which faults degrade the system versus stop the robot?
- How do you re-enter normal mode safely?
- What should an operator see after a failed run?

### Question 8: Cross-Functional Performance Contract

Researchers want a new policy that needs 3 cameras, higher resolution, and more telemetry. Platform engineers are concerned about thermal limits and missed deadlines.

Define the integration contract.

Be explicit about:

- Latency and throughput budgets per stage.
- Required model input timing contract.
- Allowed camera formats and frame rates.
- Resource ownership for CPU, GPU/NPU, memory bandwidth, network, and storage.
- Rollout gates before enabling full-speed robot evaluation.
- How you communicate tradeoffs to researchers and operators.

Follow-up:

- What do you do when the model's ideal input contract is incompatible with real-time safety?
- How do you test a new pipeline without risking hardware?

## Interviewer Calibration

Strong L4 signal:

- Separates hard real-time control from best-effort inference, logging, and streaming.
- Uses bounded queues, timestamps, sequence numbers, and explicit stale-data policy.
- Knows practical Linux tools and can propose plausible scheduling, affinity, and I/O containment.
- Designs camera buffering and video drop policies around latency rather than completeness.
- Provides concrete metrics and pass/fail thresholds.

Strong L5 signal:

- Quantifies end-to-end budgets and per-stage ownership across OS, drivers, middleware, and application code.
- Designs observability that can localize rare latency spikes across distributed components.
- Understands when to fix application architecture versus kernel/driver/IRQ/device behavior.
- Treats learned-policy output as untrusted input and gates it before actuator commands.
- Anticipates recovery, rollout, thermal behavior, operator workflow, and cross-team integration risks.

Weak signals:

- Lets cameras, inference, networking, logging, allocation, or locks block the control loop.
- Optimizes average latency while ignoring p99, jitter, queue age, and deadline misses.
- Uses unbounded queues that preserve old frames or stale commands.
- Cannot explain Linux scheduling, IRQ affinity, page faults, or tracing strategy.
- Provides no numeric release gates or production debugging plan.
