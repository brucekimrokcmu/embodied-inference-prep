# Physical Intelligence Toy Project: Jetson Orin Nano + Webcams + SO-101 Runtime

**Section:** Company-Specific Toy Project  
**Target Role:** Physical Intelligence Robotics Software Engineer  
**Hardware:** Jetson Orin Nano, 1-2 USB webcams, SO-101 robot arm  
**Goal:** Build a tiny but interview-grade robot runtime project that lets you answer the Pi loop through concrete implementation, measurements, and tradeoffs.

## Project Prompt

Build a minimal real-time-ish robot runtime on Jetson Orin Nano that captures webcam frames, runs a lightweight perception or policy placeholder, publishes safe command references, and drives or simulates SO-101 control while collecting enough timing data to debug p99 latency.

Start with an intentionally unoptimized vanilla runtime. Use ordinary OpenCV webcam capture, straightforward C++ threads, simple queues or mutex-protected mailboxes, a policy stub, and plain CSV logging. Make it correct, safe, and measurable before optimizing anything.

Only after the vanilla runtime works should you replace one subsystem at a time with a more production-like version. Each optimization must have a before/after measurement and a clear reason: lower p99 latency, lower jitter, fewer copies, safer ownership, less control-loop interference, or better failure recovery.

The project does not need to solve a complex manipulation task. It should demonstrate that you can evolve the platform underneath learned policies from a simple baseline into a bounded, debuggable runtime: native resource lifetime, zero-copy-aware buffer ownership, control handoff, profiling, safe fallback, and research/runtime contracts.

## Demo Behavior

The demo should support one of these tiny tasks:

1. **Color Target Servo:** webcam detects a colored object and commands SO-101 end-effector deltas toward the target.
2. **AprilTag/Marker Tracking:** webcam estimates marker center and commands bounded pan/reach motions.
3. **Policy Stub Replay:** a recorded or scripted policy publishes action deltas while webcams and logging create realistic load.

The task can run slowly and safely. The engineering value is in proving that the runtime stays bounded and debuggable under sensor, inference, logging, and control workload.

## Required Architecture

Implement these components first in vanilla form, then optimize selectively:

- `camera_capture`: captures frames from 1-2 webcams with sequence numbers and timestamps.
- `frame_ring`: bounded SPSC ring or latest-frame mailbox passing `FrameDesc` objects, not image payload copies.
- `preprocess_infer`: runs OpenCV processing, TensorRT/ONNXRuntime/TorchScript, or a deterministic policy stub.
- `action_bridge`: converts perception/policy output into bounded SO-101 references with `valid_until_ns`.
- `control_loop`: runs at a fixed target rate, for example 50-100 Hz, consumes only fresh validated references, and sends commands or simulated commands.
- `logger`: drains timing events asynchronously without blocking control.
- `supervisor`: tracks camera timeout, stale action, actuator/API failure, thermal warning, and controlled stop.

## Implementation Plan

### Phase 0: Vanilla Runtime First

Build the simplest version that proves the end-to-end behavior:

- Use OpenCV `VideoCapture` for webcams.
- Use a deterministic policy stub or simple color detector.
- Use ordinary `std::thread` workers.
- Use `std::mutex` plus a latest-value mailbox where convenient.
- Use `std::vector` or `cv::Mat` normally; do not force zero-copy yet.
- Use CSV or JSONL logs.
- Send conservative SO-101 commands or run in simulation/dry-run mode.
- Print a short end-of-run latency summary.

Vanilla success criteria:

- webcam frames are captured or synthetic frames replay.
- action references are published with timestamps and `valid_until_ns`.
- the control loop runs for 5 minutes at 50-100 Hz.
- stale actions are rejected.
- the robot can hold/stop safely.
- the profiling report shows p50/p95/p99/max timing for each stage.

This phase gives you the baseline interview story: "Here is the working system, here are the measured bottlenecks, and here is why I optimized the next layer."

### Phase 1: Runtime Optimization Targets

Optimize one component at a time. Do not rewrite the whole system at once.

| Runtime Part | Vanilla Baseline | Optimization Goal | Evidence to Collect |
| --- | --- | --- | --- |
| Camera capture | OpenCV `VideoCapture`, copied `cv::Mat` frames | Move toward V4L2, stable timestamps, bounded buffering, optional DMABUF export | frame interval p95/p99, capture-to-dequeue latency, dropped/bursty frames |
| Frame handoff | mutex-protected latest frame or simple queue | SPSC ring or latest-frame mailbox carrying descriptors/slot ids | queue age, push/pop cost, drop count, no unbounded growth |
| Buffer ownership | ordinary heap/image objects | fixed slot pool, explicit owner/recycle states, DMABUF-ready `FrameDesc` | copy count, slot starvation, use-after-recycle tests |
| Preprocess/policy | CPU OpenCV color detector or policy stub | preallocated working buffers, optional TensorRT/ONNXRuntime, static shapes | preprocess p95/p99, inference p95/p99, allocation count |
| Action bridge | direct bounded command conversion | freshness contract, physical limits, rate limits, generation/model versioning | rejected stale/unsafe actions, max command age |
| Control loop | fixed-rate thread with simple sleep | no steady-state allocation, no blocking waits, optional affinity/RT priority | tick duration p95/p99/max, wakeup jitter, deadline misses |
| Logger | direct CSV writes or buffered stream | async ring-buffer logger with drop counters | logger latency, dropped trace events, control impact during storage stress |
| Supervisor | simple status flags | explicit states: normal, degraded sensor, stale policy, controlled stop, fault | time to detect fault, recovery behavior, operator-visible reason |
| Jetson system | default power/thermal settings | tegrastats capture, thermal soak, optional clocks/frequency policy | temperature, CPU/GPU frequency, throttling, latency under soak |
| Video display/streaming | optional local display | isolate display/streaming from control-critical work | control jitter with and without display/streaming |

Optimization rule:

- Change one runtime part.
- Run the same benchmark before and after.
- Keep the change only if it improves a stated goal or makes ownership/safety clearer.
- Record the tradeoff, including complexity added.

## Interview Questions This Project Should Answer

### 1. C++ Resource Lifetime and Model/Runtime Ownership

Show how your code owns:

- webcam handles or V4L2/OpenCV capture objects.
- native FDs if you use V4L2 or DMABUF.
- frame slots and image buffers.
- model/runtime objects if you use TensorRT, ONNXRuntime, PyTorch, or a policy stub.
- SO-101 bus/API handles.

Prepare to explain:

- What is move-only?
- What is borrowed?
- What can be shared safely?
- What must be destroyed after in-flight work completes?
- What is forbidden on the control loop?

### 2. DMABUF / Zero-Copy-Aware Buffer Design

Even if the first implementation uses OpenCV copies, design the buffer contract as if it could be upgraded to V4L2/DMABUF.

Your design should include:

- `FrameDesc` with `seq`, `capture_time_ns`, `camera_id`, `slot_id`, and optional `dma_buf_fd`.
- A fixed buffer pool or bounded mailbox.
- A clear owner for each slot.
- A recycle rule after preprocessing/inference completes.
- Notes on where cache sync or device fences would be required in a real DMABUF path.

Deliverable:

- A short `docs/design/buffer_lifecycle.md` diagram or section showing capture -> preprocess -> inference -> recycle.

### 3. NPU/GPU/System Latency Profiling

Instrument the runtime so a failed run can answer where latency was introduced.

Trace at minimum:

- frame captured.
- frame dequeued/read by preprocess.
- inference or policy start/end.
- action published.
- control tick start/end.
- action accepted/rejected.
- SO-101 command write attempted/completed.
- logger enqueue/drop.

Collect:

- p50/p95/p99/max stage latency.
- queue age and queue depth.
- dropped frames.
- stale actions.
- control loop deadline misses.
- Jetson temperature, CPU/GPU frequency, and throttling state when available.

Prepare to explain how you would distinguish:

- model compute latency.
- scheduler delay.
- page faults or allocation.
- camera burstiness.
- logging or storage stalls.
- thermal throttling.

### 4. Control Loop Jitter Under Mixed Workload

Add a stress mode that runs camera capture, inference/policy, video display or streaming, and logging while the control loop continues.

Control-loop requirements:

- target rate: 50-100 Hz.
- no heap allocation in steady-state control tick.
- no blocking on camera, inference, display, network, or storage.
- stale action rejection at consume time.
- bounded hold or controlled stop when action age exceeds threshold.

Experiments:

- baseline idle control loop.
- camera-only load.
- camera + inference/policy load.
- camera + inference/policy + logging load.
- optional camera + inference/policy + video streaming load.

For each experiment, report p95/p99/max tick duration and deadline miss count.

### 5. Practical SPSC Frame Ring

Implement a C++17/20 SPSC ring for frame descriptors:

```cpp
struct FrameDesc {
  uint64_t seq;
  uint64_t capture_time_ns;
  uint32_t camera_id;
  int dma_buf_fd;
  uint32_t slot_id;
};
```

Requirements:

- no dynamic allocation after construction.
- `try_push` returns `false` when full.
- `try_pop` returns `false` when empty.
- producer publishes descriptor before advancing write index.
- consumer acquires write index before reading descriptor.
- producer and consumer indices avoid false sharing.

Add a small unit test or standalone benchmark that pushes and pops synthetic frame descriptors.

### 6. Research Runtime Contract

Write a one-page contract for a hypothetical researcher who wants to replace your stub policy with a larger learned policy.

Include:

- allowed camera count, resolution, frame rate, and frame age.
- model input shape and static/dynamic shape policy.
- p95/p99 inference latency budget.
- max action age at control consumption.
- SO-101 command safety limits.
- thermal and logging requirements.
- rollout gates: offline replay, bench test, low-speed robot run, stress run, rollback criteria.

Make the contract practical: give numbers and explain which are hard safety constraints versus negotiable quality tradeoffs.

## Suggested Repository Layout

```text
toy_projects/pi_jetson_so101_runtime/
  CMakeLists.txt
  README.md
  include/
    frame_desc.h
    spsc_ring.h
    trace_event.h
    safe_action.h
  src/
    main.cpp
    camera_capture.cpp
    policy_stub.cpp
    action_bridge.cpp
    control_loop.cpp
    telemetry_logger.cpp
    supervisor.cpp
  tests/
    test_spsc_ring.cpp
    test_stale_action.cpp
  docs/
    architecture.md
    buffer_lifecycle.md
    profiling_report.md
    research_runtime_contract.md
```

## Minimum Acceptance Criteria

- Runs on Jetson Orin Nano or a development machine in simulation mode.
- Captures webcam frames or replays synthetic frames.
- Runs control loop for at least 5 minutes without blocking on capture, inference, logging, or display.
- Produces a profiling report with p50/p95/p99/max latency for each stage.
- Demonstrates stale-action rejection and controlled hold/stop behavior.
- Includes SPSC ring tests.
- Includes a short written answer mapping the project back to Pi interview modules.

## Stretch Goals

- Use V4L2 instead of OpenCV capture.
- Use V4L2 DMABUF export or a DMABUF-like abstraction.
- Add TensorRT inference on Jetson Orin Nano.
- Pin control and worker threads to different CPU cores.
- Add `mlockall`, preallocation, and page-fault counters.
- Add ftrace/perf/tegrastats capture scripts.
- Add video streaming and prove it does not perturb control timing.
- Implement a model hot-swap or policy reload path with generation-counted contexts.

## Final Presentation

Prepare a 10-minute walkthrough:

1. Show the architecture diagram and thread ownership.
2. Explain buffer lifetime and the SPSC handoff.
3. Show the control-loop stale-action policy.
4. Show profiling results under baseline and stress load.
5. Explain one bottleneck you found and how you proved it.
6. Present the research/runtime contract and rollout gates.

The best answer is not the most complex robot behavior. The best answer is a small system whose timing, ownership, failure modes, and tradeoffs are concrete enough to defend in an interview.
