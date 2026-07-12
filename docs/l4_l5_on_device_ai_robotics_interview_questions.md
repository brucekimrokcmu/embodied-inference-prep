# L4/L5 On-Device AI Inference and Robotics Runtime Interview Questions

This question bank targets a Senior Software Engineer role focused on on-device AI inference, robotics runtimes, embedded accelerators, and real-time physical systems. It is calibrated for Google L4/L5-equivalent scope:

- L4: independently owns major runtime modules, edge inference paths, profiling work, and optimization deliverables.
- L5: designs system architecture, connects ML research code to physical hardware runtimes, and drives cross-functional decisions across ML, autonomy, firmware, silicon, and controls teams.

## Core Questions

1. Tell me about a time you optimized an ML inference pipeline on constrained hardware. What was the bottleneck, how did you prove it, and what changed after your optimization?
   - Evaluates: production optimization depth, profiling discipline, ownership.
   - Strong signals: quantitative before/after metrics, p50/p95/p99 latency, memory bandwidth, accelerator utilization, thermal impact.
   - Weak signals: vague speedup claims, no profiler evidence, no production constraints.
   - Follow-up: What would you do if the same fix improved average latency but worsened tail latency?

2. A VLA model must run inside a 200 Hz robotics control loop, but inference latency has high jitter. How would you debug and reduce average latency and tail latency?
   - Evaluates: real-time reasoning, jitter control, system isolation.
   - Strong signals: deadline budget decomposition, thread priority, CPU affinity, bounded queues, preallocation, cache locality, accelerator scheduling.
   - Weak signals: only suggests a faster model or larger hardware.
   - Follow-up: Which work must never run on the control-loop thread?

3. How would you decide whether to use quantization, pruning, operator fusion, graph rewriting, batching, or runtime-level changes?
   - Evaluates: optimization strategy and tradeoff judgment.
   - Strong signals: bottleneck-first decision process, accuracy checks, memory footprint, operator coverage, calibration data, hardware backend constraints.
   - Weak signals: applies quantization as a default answer without diagnosis.
   - Follow-up: When can INT4 be worse than INT8 even if the model is smaller?

4. Explain how you would move a PyTorch or JAX model into a production embedded runtime such as LiteRT/TFLite, ONNX Runtime, TensorRT, Core ML, or a custom accelerator backend.
   - Evaluates: model lowering and deployment fluency.
   - Strong signals: export path, unsupported op handling, static shapes, graph rewrites, quantization calibration, backend validation, numerical parity tests.
   - Weak signals: treats export as a single command.
   - Follow-up: How do you debug a correctness regression after conversion?

5. A model performs well in simulation but causes unstable behavior on hardware. How would you determine whether the issue is model quality, sensor timing, runtime latency, controller integration, or hardware limits?
   - Evaluates: sim-to-real debugging and cross-functional diagnosis.
   - Strong signals: timestamp tracing, replay logs, hardware-in-the-loop tests, latency injection, controller contract checks, sensor synchronization.
   - Weak signals: assumes the ML model is wrong without isolating the system.
   - Follow-up: How would you reproduce the failure deterministically?

6. Describe how you would build a zero-copy multi-camera and IMU ingestion pipeline for real-time robotic inference.
   - Evaluates: embedded data path design.
   - Strong signals: DMABUF/ION/shared memory, ownership/lifetime rules, timestamp alignment, backpressure, bounded buffers, cache coherency.
   - Weak signals: copies frames through multiple queues or serializes large payloads.
   - Follow-up: How do you prevent stale frames from reaching the policy?

7. How do you profile memory bandwidth, cache behavior, compute stalls, and accelerator utilization on edge hardware?
   - Evaluates: profiling tool knowledge and hardware awareness.
   - Strong signals: perf/eBPF, Nsight, vendor profilers, hardware counters, tracing, flame graphs, allocator instrumentation.
   - Weak signals: relies only on wall-clock timing.
   - Follow-up: What symptoms suggest memory bandwidth, not compute, is the bottleneck?

8. What are the tradeoffs between CPU, GPU, NPU, DSP, TPU, and ANE execution for robotics inference workloads?
   - Evaluates: accelerator selection and workload partitioning.
   - Strong signals: startup overhead, operator support, determinism, memory transfer cost, power, thermal behavior, precision support.
   - Weak signals: ranks accelerators only by peak TOPS/FLOPS.
   - Follow-up: When is CPU execution the right answer?

9. How would you preserve task accuracy while reducing model parameters and working memory by 2x to 4x?
   - Evaluates: compression strategy.
   - Strong signals: representative calibration data, QAT/PTQ tradeoffs, distillation, activation memory analysis, accuracy gates, task-level evaluation.
   - Weak signals: focuses only on weight size.
   - Follow-up: Which metric matters more: model accuracy or closed-loop task success?

10. Tell me about a time you influenced ML researchers, firmware engineers, or hardware teams to change a design for production constraints.
    - Evaluates: L5 cross-functional leadership.
    - Strong signals: clear technical tradeoff, evidence, stakeholder alignment, durable interface or process change.
    - Weak signals: describes only implementation work with no influence.
    - Follow-up: What did you change in the design review process afterward?

## System Design Questions

1. Design an on-device inference runtime for a humanoid robot running camera, language, and action models under strict latency, thermal, and battery constraints.
2. Design a deployment pipeline that takes a research model from training, validates it in simulation, compresses it, compiles it for edge hardware, and safely rolls it out to a fleet.
3. Design a profiling and observability system for inference latency, missed control deadlines, dropped sensor frames, memory spikes, and accelerator utilization.
4. Design a runtime abstraction layer that lets the same robot policy run across CPU, GPU, NPU, TPU, and vendor-specific delegates.
5. Design a fail-safe execution path when the primary learned policy exceeds its latency budget or emits low-confidence actions.

For system design answers, expect candidates to define latency budgets, data ownership, threading models, backend dispatch, fallback behavior, validation gates, and rollout metrics. L5 answers should explicitly cover interfaces between ML research, runtime, firmware, controls, and hardware teams.

## Low-Level C++ and Runtime Questions

1. How would you implement a bounded, lock-free handoff between sensor ingestion and inference without blocking a control loop?
2. What allocation strategy would you use for predictable inference memory, and how would you prove it does not fragment under load?
3. How would you design a custom operator registration path for an embedded runtime?
4. How would you handle accelerator buffer lifetime when tensors are shared across camera, preprocessing, inference, and control stages?
5. How would you structure a thread pool for mixed-priority inference, preprocessing, logging, and motor-control-adjacent work?
6. What C++ ownership model would you use for native hardware file descriptors, DMA buffers, and compiled model handles?
7. How would you safely recover from an accelerator reset without corrupting the robot's runtime state?

## ML Deployment and Optimization Questions

1. How do you validate numerical parity between a research model and an optimized edge runtime model?
2. How do static and dynamic shapes affect graph compilation and real-time inference?
3. What makes an operator fusion profitable, and when can fusion hurt performance?
4. How do you choose calibration data for post-training quantization of a robotics model?
5. How do you evaluate whether a runtime optimization changed closed-loop behavior?
6. How would you support unsupported PyTorch/JAX operations in a production runtime?
7. What deployment gates should block a compressed model from shipping to physical robots?

## Robotics, Sensors, and Control Questions

1. How should inference outputs be versioned against the sensor snapshot and robot state that produced them?
2. How would you integrate learned inference into ROS 2 while preserving bounded execution behavior?
3. How would you design backpressure when cameras produce frames faster than inference can consume them?
4. How would you prevent inference work from causing priority inversion in a motor-control system?
5. How would you handle stale, missing, or partially corrupted sensor inputs?
6. How would you test a runtime under walking, manipulation, and thermal stress instead of only bench conditions?
7. How would you separate safety-critical fallback control from best-effort learned policy execution?

## Company-Specific Questions

### Google DeepMind

Focus: research-to-product bridge, JAX, MuJoCo, TPUs, LiteRT/XNNPACK, reusable SDKs.

1. How would you convert a JAX-based robotics research model into a deployable runtime for real robots?
2. How would you design an SDK that lets external robotics partners deploy learned policies across different robot embodiments?
3. What abstractions would you expose to researchers versus production robotics engineers?
4. How would you validate that a policy trained in MuJoCo behaves safely and reliably on physical hardware?
5. How do you balance research flexibility with production runtime stability?

### Tesla

Focus: scaled production, proprietary silicon, OTA deployment, automated validation, fleet reliability.

1. How would you build an automated pipeline for quantizing, validating, compiling, and deploying robot models to thousands of devices?
2. A model runs correctly on one robot but intermittently misses deadlines across the fleet. How would you debug this?
3. How would you optimize a perception-to-action model for proprietary automotive or robotics silicon?
4. How would you evaluate whether INT4 quantization is acceptable for a safety-critical robotics policy?
5. What metrics would you track before allowing an OTA model or runtime update to ship?

### Apple

Focus: on-device intelligence, privacy, Apple Neural Engine/Core ML, power efficiency, product quality.

1. How would you optimize a robotics, spatial AI, or multimodal model for Apple Neural Engine or Core ML execution?
2. How would you balance model quality, battery life, thermals, and user experience on an Apple device?
3. How would you debug a model that performs well in PyTorch but regresses after Core ML conversion?
4. What runtime metrics matter most for always-on or interactive on-device AI?
5. How would you design a privacy-preserving on-device inference pipeline for sensor-heavy applications?

### Figure AI

Focus: embedded humanoid robotics, heterogeneous compute, Android NDK, custom HALs, thermal and battery constraints.

1. How would you partition workloads across CPU, GPU, DSP, and NPU on a humanoid robot?
2. How would you build a deterministic sensor pipeline for high-FPS cameras and high-frequency IMU data?
3. What are the risks of using Android/Linux-style runtime environments in a real-time robotic control system?
4. How would you debug dropped frames in a zero-copy camera pipeline?
5. A robot's inference stack works well on a bench but overheats during walking tasks. How would you approach the problem?

### Skild AI

Focus: general-purpose robotics foundation models, sim-to-real, policy learning, scalable deployment across embodiments.

1. How would you deploy a general-purpose robot policy across multiple robot morphologies?
2. How would you structure a runtime that supports both learned low-level control and high-level VLA reasoning?
3. How would you test whether a foundation robotics model generalizes beyond its training embodiments?
4. How would you handle latency when a large model must interface with fast physical controllers?
5. What runtime abstractions are needed for a robotics foundation model company?

### Anduril

Focus: defense autonomy, edge compute, reliability in degraded environments, safety-critical systems.

1. How would you deploy ML inference on autonomous systems operating with limited network connectivity?
2. How would you design an edge inference stack for harsh environments with strict power and thermal limits?
3. How would you validate model and runtime behavior for safety-critical autonomous missions?
4. How would you handle degraded sensors, intermittent compute pressure, or partial hardware failure?
5. What engineering practices would you use when runtime failure could have mission or safety consequences?

### NVIDIA

Focus: platform engineering, CUDA, TensorRT, Jetson, Isaac, ROS 2, ecosystem APIs.

1. How would you optimize a robotics model for Jetson using CUDA, TensorRT, and Nsight?
2. How would you design reusable APIs for contact-rich manipulation or sim-to-real robotics workflows?
3. How would you integrate an inference runtime into ROS 2 while preserving real-time behavior?
4. How would you make a robotics runtime portable across Jetson, desktop GPUs, and cloud GPUs?
5. What makes a developer-facing robotics platform reliable enough for third-party OEMs?

## Behavioral and Level Calibration

1. Describe a module or subsystem you owned end-to-end. What decisions were yours?
2. Tell me about a performance bottleneck others had missed. How did you find and fix it?
3. Tell me about a time you pushed back on a model architecture because it was not deployable.
4. How do you decide when to write custom low-level code versus use an existing runtime?
5. How would you set technical direction for a team building robotics inference infrastructure?
6. How do you handle disagreement between research velocity and production reliability?
7. How do you communicate risk when a runtime issue can affect physical robot safety?

L4 answers should show independent execution, strong debugging, clear module ownership, and reliable delivery. L5 answers should show architectural judgment, durable interfaces, cross-team influence, and the ability to change how the organization ships models to physical hardware.

## Deep-Dive Scenarios with Stored Sample Answers

Use this section for high-signal prompts that include hard constraints and explicit evaluation criteria. Keep each scenario paired with a stored sample answer so interview practice is concrete and repeatable.

### Scenario A: VLA-to-Control Handoff Under Jitter (LiteRT)

#### Interview Question

You are deploying a Gemini-based Vision-Language-Action (VLA) model to an on-device robotics platform using LiteRT (formerly TensorFlow Lite).

- The Inference Thread processes camera frames and runs model inference asynchronously. Because it is an autoregressive model executing heavy matrix multiplication on an NPU delegate, its latency fluctuates between 15 ms and 45 ms (high jitter).
- The Control Thread runs a critical real-time actuator loop at 200 Hz (5 ms deadline budget). If this thread experiences a stall greater than 5 ms, the robot enters an unrecoverable fault state.

Write a production-grade C++ data-structure and thread-handoff component to safely pass the latest computed action tensor from the Inference Thread to the Control Thread.

Your implementation must satisfy these strict real-time constraints:

1. Zero Heap Allocation: No calls to malloc, new, std::vector resizing, or smart pointer creations are allowed during steady-state execution.
2. Lock-Free Execution on the Control Thread: The Control Thread must never block on a mutex, condition variable, or spinlock held by the lower-priority Inference Thread (preventing priority inversion).
3. Buffer Lifetime Management: Manage underlying LiteRT tensor buffers (TfLiteTensor or raw DMA-BUF memory handles) so the Inference Thread can prepare a new output slot without tearing or corrupting data currently read by the Control Thread.

#### L4/L5 Evaluation Matrix

| Dimension | L4 Expected Signal (Independent Module Owner) | L5 Expected Signal (System Architect) |
| --- | --- | --- |
| Concurrency and Threading | Implements a functional thread-safe ring buffer; uses basic atomic flags or fences. | Implements a true lock-free SPSC queue; uses relaxed vs. acquire-release memory semantics intentionally. |
| Real-Time Safety | Avoids standard mutexes on the real-time thread; no explicit new/delete in steady state. | Avoids implicit allocations and protects against false sharing using cache-line alignment. |
| Memory and Lifetime | Implements basic double/triple buffering to prevent tearing. | Implements ownership token/index handoff and coordinates lifetime with LiteRT external buffers or DMA-BUF lifecycle callbacks. |
| Failure Modes | Detects overflow/underflow and reports status. | Designs freshness/backpressure policy and deterministic fallback controller behavior when inference misses deadlines. |

#### Stored Sample Answer

See the stored full sample answer in [docs/practice/l4_l5_low_level_cpp_sample_answers.md](docs/practice/l4_l5_low_level_cpp_sample_answers.md).

### Scenario B: Zero-Copy Multi-Camera and IMU Ingestion

#### Interview Question

Design a C++ ingestion subsystem where three cameras (60 FPS each) and one IMU stream (1 kHz) feed a real-time policy without frame copying in steady state.

Constraints:

1. Use DMA-BUF or equivalent external memory handles; no per-frame heap allocations after startup.
2. Enforce timestamp alignment policy: reject sensor bundles with max skew greater than 2 ms.
3. Add bounded backpressure policy that drops stale frames first and preserves freshest control-relevant data.
4. Ensure ownership/lifetime is explicit so no stage reads freed or recycled buffers.

#### Stored Sample Answer

See Scenario B in [docs/practice/l4_l5_low_level_cpp_sample_answers.md](docs/practice/l4_l5_low_level_cpp_sample_answers.md).

### Scenario C: ROS 2 Integration with Bounded Execution

#### Interview Question

Integrate learned policy inference into ROS 2 while preserving deterministic execution for a 200 Hz control loop.

Constraints:

1. Control callback must never wait on inference completion.
2. Logging and telemetry must be non-blocking and bounded.
3. Executor and callback-group design must prevent priority inversion between control-critical and best-effort callbacks.
4. If model output is stale by more than 20 ms, control path must switch to deterministic fallback behavior.

#### Stored Sample Answer

See Scenario C in [docs/practice/l4_l5_low_level_cpp_sample_answers.md](docs/practice/l4_l5_low_level_cpp_sample_answers.md).

### Scenario D: Quantization Regression After Conversion

#### Interview Question

A PyTorch policy passes simulation gates, but after LiteRT INT8 conversion it shows a 12 percent drop in closed-loop task success and increased oscillation near contact.

Constraints:

1. Build a debugging and validation plan that isolates numeric parity, runtime latency, and control-loop effects.
2. Provide hard deployment gates that block unsafe model release.
3. Keep evaluation reproducible with replay datasets and hardware-in-the-loop checks.

#### Stored Sample Answer

See Scenario D in [docs/practice/l4_l5_low_level_cpp_sample_answers.md](docs/practice/l4_l5_low_level_cpp_sample_answers.md).

### Scenario E: Accelerator Reset and Runtime Recovery

#### Interview Question

During walking tasks, the NPU delegate occasionally resets. Design a C++ runtime recovery path that preserves control-loop safety and avoids state corruption.

Constraints:

1. Control loop must continue at 200 Hz during reset handling.
2. In-flight buffers and model handles must transition through explicit states (ready, invalid, rebuilding).
3. Recovery must be bounded and observable, with automatic rollback if reinitialization exceeds deadline budget.

#### Stored Sample Answer

See Scenario E in [docs/practice/l4_l5_low_level_cpp_sample_answers.md](docs/practice/l4_l5_low_level_cpp_sample_answers.md).

## Recommended Answer Structure

Use this format when practicing:

1. State the system constraint: latency, memory, power, thermal, safety, or deployability.
2. Identify the bottleneck or risk with measurement, not assumption.
3. Propose the architecture or optimization.
4. Explain validation: unit tests, replay tests, simulation, hardware-in-the-loop, fleet canary, or task-level success metrics.
5. Discuss tradeoffs and failure modes.
6. Close with production metrics and rollback/fallback behavior.
