# Microsoft AI Frameworks Hint Set: Senior Software Engineer

**Section:** Company-Specific Runtime and AI Infrastructure Interviews

## Hint 1: Cross-Device Runtime Contract

Think in layered contracts:
- Stable IR/runtime API.
- Backend capability registry.
- Deterministic fallback path.

Explicitly define what can vary by backend (performance) vs what must not vary (semantic correctness, tolerance envelopes).

## Hint 2: Tail-Latency Regression

Median improved but p99 degraded usually means queueing or contention effects. Inspect:
- Queue wait time vs service time split.
- Batch formation delays.
- Memory reclaim pauses.
- Network retry/retransmit spikes.

Instrument before tuning to avoid moving bottlenecks blindly.

## Hint 3: Memory Planning Under Dynamic Shapes

Combine static planning for common shape buckets with bounded dynamic pools for outliers. Consider:
- Lifetime-based buffer reuse.
- Arena partitioning by tensor class.
- Fragmentation metrics and eviction/admission controls.

## Hint 4: Release Gating and Reliability

Use progressive confidence:
- Offline numerical parity corpus.
- Hardware matrix perf benchmarks.
- Canary with automatic rollback triggers tied to SLO and quality metrics.

Store versioned artifacts and traces so regressions are bisectable.
