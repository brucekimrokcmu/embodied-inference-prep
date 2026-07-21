# Physical Intelligence Sample Answers: Runtime Software Engineer

**Section:** Company-Specific Runtime Systems Interviews

## Answer 1: Sensor-to-Actuator Latency Budget

I would architect a split pipeline with strict ownership and deterministic fallback:

1. Topology:
- `capture_rt` thread: synchronized camera+IMU ingest, hardware timestamp normalization.
- `preprocess_worker`: format conversion, lightweight filtering.
- `inference_worker`: executes model delegate.
- `control_rt` thread (highest priority): consumes latest valid action and emits actuator command every 5 ms.

2. Scheduling:
- `control_rt`: `SCHED_FIFO` on isolated core.
- `capture_rt`: next-highest RT priority.
- inference/preprocess/logging on non-isolated cores.

3. Handoff:
- SPSC lock-free ring for each boundary with preallocated fixed-size slots.
- Queue payload carries slot ID + timestamp + sequence, not deep-copied tensors.

4. Freshness contract:
- At control consume, reject action if age > 20 ms.
- If rejected or absent, issue deterministic hold/stabilization command.

5. Rollout gates:
- p99 sensor-to-actuator latency < 12 ms.
- missed-deadline rate < 0.1% at 200 Hz.
- fallback engagement rate within safety envelope.
- thermal steady-state does not degrade p99 over 30-minute run.

Minimal consume gate example:

```cpp
if (!maybe_action || now_ns - maybe_action->timestamp_ns > 20ULL * 1000ULL * 1000ULL) {
  ExecuteSafetyFallbackHold();
} else {
  ExecuteActuatorCommand(maybe_action->joint_commands);
}
```

## Answer 2: Camera Jitter and Packet Scheduling

I would use latency-bounded streaming rather than completeness-oriented streaming:

1. Packetization:
- Frame chunks carry `{stream_id, frame_seq, chunk_seq, capture_ts_ns, deadline_ts_ns}`.
- Control metadata channel separate from bulk image channel.

2. Scheduling:
- Token-bucket pacing per stream to prevent burst collapse.
- Priority queue where control metadata and key timing markers are dequeued first.

3. Receiver:
- Small reorder window (for example 2-3 frames max) keyed by `frame_seq`.
- Late frame policy: if frame arrival exceeds display/control budget, drop and advance.

4. Overload strategy:
- Drop oldest non-key frames first.
- Degrade payload resolution/quality before sacrificing control metadata.

5. Validation:
- Track p50/p95/p99 inter-frame arrival jitter.
- Track reordering depth and late-drop ratio.
- Confirm control-loop deadline misses do not increase during network contention tests.

## Answer 3: Linux Determinism Under Mixed Workloads

I would hard-partition critical and best-effort execution paths:

1. CPU isolation:
- Reserve one core exclusively for `control_rt`.
- Pin logging/recording threads to separate cores.

2. Scheduling policy:
- `control_rt` as `SCHED_FIFO` with bounded critical sections.
- Any shared lock in RT path must be replaced by lock-free handoff or priority-inheritance mutex with measured contention ceiling.

3. Memory behavior:
- Preallocate RT buffers and pre-fault memory.
- Disable allocator use on RT thread in steady state.

4. IO containment:
- Async log ring to non-RT writer thread.
- cgroup IO weights/limits so flush spikes cannot starve control.

5. Observability:
- `perf sched`, ftrace, and eBPF traces to attribute wakeup latency.
- Histograms for loop jitter and deadline misses under synthetic IO stress.

## Answer 4: Delegate/Accelerator Fault Recovery

State machine design:
- `Ready`
- `DegradedFallback`
- `RebuildingDelegate`
- `Rollback`

Flow:
1. Fault detector atomically transitions `Ready -> DegradedFallback`.
2. `control_rt` immediately switches to deterministic fallback controller; no waits.
3. Recovery worker enters `RebuildingDelegate`, rebuilds runtime artifacts, validates inference health and latency bounds.
4. If checks pass within 2 seconds, transition back to `Ready`.
5. Otherwise transition to `Rollback` and remain degraded until manual or automated safe reset policy executes.

Minimal state transition sketch:

```cpp
enum class RuntimeState : uint8_t { Ready, DegradedFallback, RebuildingDelegate, Rollback };

if (fault_detected && state.load(std::memory_order_acquire) == RuntimeState::Ready) {
  state.store(RuntimeState::DegradedFallback, std::memory_order_release);
  NotifyRecoveryWorker();
}
```

Required telemetry:
- `delegate_reset_count`
- `rebuild_duration_ms`
- `fallback_duration_ms`
- `deadline_miss_count_during_degraded`
- bounded event log for last N transitions and fault codes

This answer aligns with Physical Intelligence priorities: deterministic control behavior, end-to-end latency budgets, and production-grade reliability under real hardware faults.
