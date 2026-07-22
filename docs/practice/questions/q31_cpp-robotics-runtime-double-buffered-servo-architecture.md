# C++ Robotics Runtime: Double-Buffered Trajectory Handoff and Real-Time Servo Loop

## Problem Summary

You are given a prototype robot runtime for a 6-DOF arm. It has three threads:

- A non-real-time worker thread running policy inference and trajectory generation at roughly 25 to 50 Hz.
- A hard real-time servo thread running at 200 Hz.
- An async logger thread that writes telemetry to disk.

The prototype uses:

- an atomic pointer to publish the latest `TrajectorySegment`,
- two trajectory buffers for double buffering,
- a lock-free ring buffer for logging,
- a local trajectory copy inside the servo loop,
- `sleep_until()` to maintain a 5 ms cycle.

The team wants to turn this prototype into production-quality runtime code suitable for robot hardware.

## Starter Context

Assume these simplified data contracts:

```cpp
constexpr size_t kNumJoints = 6;

struct HighLevelGoal {
  std::array<double, 3> target_xyz;
  uint64_t sequence_id;
};

struct TrajectorySegment {
  std::array<double, kNumJoints> q_start;
  std::array<double, kNumJoints> q_goal;
  std::array<double, kNumJoints> qd_goal;
  double duration_sec;
  uint64_t trajectory_id;
  uint64_t publish_time_ns;
  uint64_t valid_until_ns;
};

struct ActuatorCommand {
  std::array<double, kNumJoints> q_des;
  std::array<double, kNumJoints> qd_des;
  std::array<double, kNumJoints> tau_ff;
};

struct RobotState {
  std::array<double, kNumJoints> q_actual;
  std::array<double, kNumJoints> qd_actual;
};
```

The current implementation conceptually does this:

```cpp
// Worker thread:
//   sleep 40 ms to simulate inference
//   write next trajectory into one of two buffers
//   publish pointer with active_trajectory.store(ptr, release)

// Servo thread, every 5 ms:
//   read actuator state
//   latest = active_trajectory.exchange(nullptr, acquire)
//   if latest != nullptr: local_traj = *latest
//   interpolate local_traj
//   write actuator command
//   push telemetry into lock-free log buffer

// Logger thread:
//   pop telemetry and write it to disk
```

## Your Task

Redesign this runtime architecture for production use.

Your answer should cover correctness, real-time behavior, control semantics, failure handling, and validation.

## Requirements

### Part A: Architecture Review

Identify at least eight concrete issues or missing pieces in the prototype.

Consider:

- pointer publication and buffer lifetime,
- data races on shared robot state,
- trajectory overwrite hazards,
- stale trajectory handling,
- command discontinuities,
- interpolation correctness,
- real-time loop timing and overrun behavior,
- logging backpressure,
- memory allocation,
- actuator bus failures,
- shutdown behavior,
- missing safety gates.

For each issue, explain:

1. Why it matters on real robot hardware.
2. Whether it is a correctness bug, real-time risk, controls risk, or observability gap.
3. How you would fix or mitigate it.

### Part B: Data Contracts

Design production-grade message contracts for:

- high-level goals,
- trajectory segments,
- actuator commands,
- robot state,
- telemetry log entries.

Each contract should include the fields needed for:

- timestamping,
- sequence tracking,
- freshness checks,
- coordinate/unit conventions,
- safety status,
- command mode,
- saturation and fault reporting.

### Part C: Non-Blocking Handoff

Design a safe handoff mechanism from the worker thread to the servo thread.

Choose one:

- double-buffered latest trajectory,
- SPSC queue,
- latest-value mailbox with sequence counter,
- fixed slot table with ownership states.

Be explicit about:

- who owns each slot,
- when a writer may overwrite a slot,
- how the servo detects a new trajectory,
- memory ordering,
- whether the servo copies data locally or references shared memory,
- what happens when the worker publishes faster than the servo consumes.

Provide C++-style pseudocode for the handoff.

### Part D: 200 Hz Servo Loop

Write pseudocode for the servo loop.

Include:

- periodic scheduling,
- actuator feedback read,
- state estimation,
- trajectory consume/sample,
- stale-data rejection,
- safety pre-check,
- control law,
- saturation/rate limiting,
- actuator write,
- telemetry append,
- deadline miss detection,
- fallback behavior.

State what operations are forbidden in this loop.

### Part E: Trajectory Semantics

The prototype computes:

```cpp
q_des[i] = q_actual[i] + alpha * (q_goal[i] - q_actual[i]);
```

Explain why this may be a poor trajectory sampler.

Design a better sampler that respects:

- fixed segment start state,
- velocity continuity,
- velocity and acceleration limits,
- monotonic segment time,
- segment replacement behavior,
- emergency stop or hold transitions.

### Part F: Lock-Free Logging

Evaluate the prototype logging ring buffer.

Discuss:

- whether dropping logs is acceptable,
- how to count dropped logs,
- acquire/release memory ordering,
- false sharing,
- fixed-size event design,
- avoiding dynamic allocation,
- how the logger handles disk stalls,
- what telemetry is required to debug a missed control deadline.

### Part G: Fault Handling and State Machine

Define a runtime state machine with at least:

- `INIT`,
- `HOLD`,
- `RUNNING`,
- `DEGRADED`,
- `CONTROL_STOP`,
- `E_STOP`.

Add concrete transitions for:

- stale trajectory,
- invalid trajectory,
- actuator feedback timeout,
- actuator write failure,
- command saturation for multiple cycles,
- encoder discontinuity,
- servo deadline miss,
- logger backpressure,
- worker/inference timeout,
- clean shutdown.

### Part H: Verification Plan

Design a test plan before enabling robot hardware.

Include:

- unit tests for handoff and ring buffer behavior,
- concurrency stress tests,
- deterministic replay tests,
- simulated actuator-bus timeout tests,
- trajectory continuity and limit tests,
- servo deadline tests under synthetic CPU and disk load,
- hardware-in-loop smoke tests,
- release thresholds.

## Follow-Up Questions

1. Why is `std::atomic<TrajectorySegment*>` not by itself enough to make the double-buffer safe?
2. What memory ordering would you use for a sequence-counter mailbox?
3. When should a latest-value mailbox be preferred over an SPSC queue?
4. How would your design change if trajectory generation produced large spline objects?
5. What should the servo do if it receives a new valid trajectory while still executing the previous one?
6. How would you prove there are no heap allocations in the real-time path?
7. What trace event would tell you whether a missed deadline came from scheduler jitter or actuator bus latency?

## Expected L4 Signals

- Separates real-time servo work from inference, planning, and logging.
- Identifies stale-data, overwrite, shutdown, and logging-backpressure problems.
- Uses bounded handoff structures and clear ownership.
- Provides reasonable acquire/release reasoning.
- Adds safety checks, telemetry, and basic release thresholds.

## Expected L5 Signals

- Designs a complete ownership/lifetime protocol, not just atomic pointer exchange.
- Connects trajectory semantics to control stability and actuator safety.
- Defines deterministic fallback behavior for every producer failure.
- Adds observability that can diagnose p99 deadline misses after the run.
- Validates with concurrency stress, fault injection, replay, HIL, and load tests.

## Weak Signals

- Assumes atomics automatically make pointed-to data safe.
- Lets the servo loop allocate, block, log to disk, or wait on worker/inference.
- Ignores stale trajectories and command discontinuities.
- Preserves old commands because "no data loss" is prioritized over freshness.
- Provides no test plan for concurrency or deadline behavior.
