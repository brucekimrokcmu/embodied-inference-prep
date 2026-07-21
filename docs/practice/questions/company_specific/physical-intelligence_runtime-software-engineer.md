# Physical Intelligence: Runtime Software Engineer (Company-Specific Question Set)

**Section:** Company-Specific Runtime Systems Interviews

## Question 1: Sensor-to-Actuator End-to-End Latency Budget

You are running a 200 Hz whole-body control loop (5 ms period) on Linux. Input pipeline is 2 synchronized cameras (60 FPS) + IMU (1 kHz), and model inference is variable from 2.2 ms to 9.1 ms under load. Propose an end-to-end runtime design that keeps p99 sensor-to-actuator latency below 12 ms while ensuring the control thread never blocks.

Be explicit about:
- Thread topology and priorities.
- Queueing strategy and ownership semantics.
- Stale-data policy and fallback thresholds.
- Metrics you would gate on before production rollout.

## Question 2: Camera Pipeline Jitter and Packet Scheduling

A robot streams RGB-D video to an offboard evaluator over a lossy Wi-Fi link. Frame deadlines are 16.7 ms at 60 FPS. Under moderate contention, packet bursts cause jitter spikes to 45 ms and frequent out-of-order frame arrivals.

Design a runtime-level mitigation plan focused on packet scheduling and pacing, not ML model changes. Explain:
- How you structure frame packetization and priority classes.
- What timing metadata and reorder buffers are required.
- What you drop first under overload (and why).
- How you verify recovery without violating control-loop correctness.

## Question 3: Linux Determinism Under Mixed Workloads

You have two classes of tasks on the same machine:
- Control-critical loop at 200 Hz.
- Best-effort evaluation/logging and dataset recording.

During long runs, occasional control misses appear when logging spikes disk I/O. Outline a Linux-level strategy to reduce jitter and protect deterministic behavior, including scheduling, CPU isolation, memory/IO controls, and kernel/runtime tuning.

## Question 4: Runtime Reliability During Delegate/Accelerator Faults

An accelerator delegate occasionally resets during dynamic maneuvers. Hard requirement: no unsafe actuator command and no deadlock in control path. Soft requirement: recover model execution within 2 seconds if possible.

Design a failure-handling state machine and describe:
- Immediate actions on fault detection.
- Recovery-worker responsibilities.
- Conditions to re-enter normal mode vs stay degraded.
- Minimal telemetry needed for postmortem and SLO tracking.
