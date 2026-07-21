# Microsoft AI Frameworks Sample Answers: Senior Software Engineer

**Section:** Company-Specific Runtime and AI Infrastructure Interviews

## Answer 1: Cross-Device Runtime Contract

I would define a three-layer execution contract:

1. Stable graph/runtime IR:
- Operator schema, shape inference, and numerical semantics are source of truth.
- Backends implement capability descriptors against this contract.

2. Capability-driven partitioning:
- During compile/load, graph partitioner maps supported subgraphs to each backend.
- Unsupported ops are explicitly assigned to fallback backend (usually CPU) with visible boundary nodes.

3. Deterministic fallback and validation:
- Every fallback edge is logged with reason code.
- Numerical parity checks run per backend pair with tolerance envelopes per op class.

ABI/API boundaries:
- Stable C API for model load/execute/teardown and tensor metadata.
- Versioned backend plugin ABI with strict compatibility tests.
- Internal scheduler implementation can evolve without changing public contract.

## Answer 2: Tail-Latency Regression Investigation

I would triage in this order:

1. Confirm symptom decomposition:
- Compare queue wait vs execution time at p50/p95/p99.
- If wait dominates p99, focus on admission, batching, and scheduler fairness.

2. Region-specific resource checks:
- CPU steal, NUMA imbalance, memory pressure/reclaim, NIC drops/retries.

3. Batching policy audit:
- Check max batch wait timeout and queue depth hysteresis.
- Reduce batch wait cap for interactive tier even if throughput drops slightly.

4. Runtime internals:
- Lock contention profiling on hot-path allocators and dispatch queues.
- Check long-tail GC/reclaim-like pauses in memory manager.

5. Rollout decision:
- If p99 exceeds SLO guardrail for canary window, auto-rollback in affected region.
- Continue partial rollout only if mitigations restore p99 while preserving error budget.

Core principle: optimize for SLO compliance first, then recover throughput.

## Answer 3: Dynamic-Shape Multi-Tenant Memory Planner

I would use hybrid planning:

1. Shape-bucket static plans:
- Precompute reuse plan for common sequence buckets (for example 128/256/512/1024).
- Allocate from per-bucket arenas to maximize locality and predictable reuse.

2. Outlier dynamic pool:
- Separate pool for rare shapes with capped footprint.
- Background compaction or recycle epochs outside latency-critical path.

3. Lifetime-aware reuse:
- Build interference graph from tensor liveness windows.
- Reuse buffers when lifetimes do not overlap.

4. Guardrails:
- Tenant-level memory quotas.
- Admission control when projected peak exceeds safe threshold.
- Degrade policy: shrink batch or context length before hard OOM.

5. Success metrics:
- Fragmentation ratio, allocation failure rate, p99 allocation latency, effective utilization.

## Answer 4: Runtime Upgrade Reliability Strategy

I would use staged quality gates:

1. Pre-merge:
- Unit + integration tests for operator correctness and scheduler invariants.
- Static checks for ABI breakage and thread-safety regressions.

2. Pre-release:
- Numerical parity suite on frozen corpora across hardware matrix.
- Performance benchmark suite with p50/p95/p99 latency and throughput.
- Long soak tests for leak and fragmentation detection.

3. Canary:
- 1-5% traffic with real-time monitors on:
  - tail latency
  - error rate
  - fallback frequency
  - model quality proxies
- Auto rollback if any metric crosses threshold for sustained window.

4. Post-release learning loop:
- Store build/runtime fingerprint, backend map, and trace IDs for each canary.
- Fast bisect path with feature flags to isolate scheduler/memory/dispatch changes.

This aligns with Microsoft AI Frameworks expectations: production-safe runtime evolution, cross-device consistency, and measurable large-scale reliability.
