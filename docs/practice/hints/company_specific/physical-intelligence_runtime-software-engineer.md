# Physical Intelligence Hint Set: Runtime Software Engineer

**Section:** Company-Specific Runtime Systems Interviews

## Hint 1: Sensor-to-Actuator Latency Budget

Think in terms of strict stage budgets that sum to < 12 ms at p99:
- Capture and timestamp.
- Preprocess and transport.
- Inference execution.
- Postprocess and control apply.

Use non-blocking handoff between stages and enforce action freshness at control consume time (for example, drop actions older than a threshold and hold stable fallback command).

## Hint 2: Camera Jitter and Packet Scheduling

Split traffic classes:
- Control-relevant metadata and timing markers at higher priority.
- Bulk frame payload at lower priority with pacing.

Use sequence numbers + monotonic timestamps so the receiver can detect gap/order issues quickly. Under overload, prefer dropping oldest or non-key frames to keep head latency bounded.

## Hint 3: Linux Determinism

Cover all four levers:
- CPU: affinity + isolated cores for critical loop.
- Scheduler: real-time policy for control thread and bounded priority inheritance points.
- Memory: pre-fault, avoid runtime allocations, lock critical pages.
- IO: isolate heavy logging paths with cgroup/io controls and async buffering.

## Hint 4: Delegate Fault Recovery

Avoid doing rebuild in the control thread. Move heavy recovery to worker thread with explicit states like:
- Ready
- DegradedFallback
- Rebuilding
- Rollback/StayDegraded

Return to Ready only after bounded health checks and latency parity checks pass.
