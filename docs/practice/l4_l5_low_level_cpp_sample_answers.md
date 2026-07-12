# L4/L5 Low-Level C++ Runtime Sample Answers

This file stores concrete, production-style sample answers for low-level runtime interview scenarios. The goal is to practice with realistic constraints, explicit failure handling, and clear L4/L5 calibration signals.

## Scenario A: VLA-to-Control Handoff Under Jitter (LiteRT)

### Problem Summary

- Inference thread latency jitter: 15 ms to 45 ms.
- Control loop deadline: 200 Hz (5 ms period).
- Hard rule: control thread must never block on lower-priority work.

### Production-Grade C++ Sample Answer

```cpp
#include <array>
#include <atomic>
#include <cstddef>
#include <cstdint>
#include <optional>

#ifdef __cpp_lib_hardware_interference_size
using std::hardware_destructive_interference_size;
#else
constexpr std::size_t hardware_destructive_interference_size = 64;
#endif

struct alignas(16) RobotAction {
  std::uint64_t timestamp_ns{0};
  std::uint64_t sequence_id{0};
  std::array<float, 7> joint_commands{};
  bool is_valid{false};
};

class RealTimeActionQueue {
 public:
  static constexpr std::size_t kCapacity = 4;
  static_assert((kCapacity & (kCapacity - 1)) == 0,
                "kCapacity must be power of two");
  static constexpr std::size_t kMask = kCapacity - 1;

  RealTimeActionQueue() noexcept = default;

  RealTimeActionQueue(const RealTimeActionQueue&) = delete;
  RealTimeActionQueue& operator=(const RealTimeActionQueue&) = delete;

  bool Push(const RobotAction& action) noexcept {
    const std::size_t read = read_index_.load(std::memory_order_acquire);
    const std::size_t write = write_index_.load(std::memory_order_relaxed);

    if ((write - read) >= kCapacity) {
      return false;
    }

    ring_[write & kMask] = action;
    write_index_.store(write + 1, std::memory_order_release);
    return true;
  }

  [[nodiscard]] std::optional<RobotAction> Pop() noexcept {
    const std::size_t read = read_index_.load(std::memory_order_relaxed);
    const std::size_t write = write_index_.load(std::memory_order_acquire);

    if (read == write) {
      return std::nullopt;
    }

    RobotAction action = ring_[read & kMask];
    read_index_.store(read + 1, std::memory_order_release);
    return action;
  }

 private:
  alignas(hardware_destructive_interference_size)
      std::array<RobotAction, kCapacity> ring_{};
  alignas(hardware_destructive_interference_size)
      std::atomic<std::size_t> write_index_{0};
  alignas(hardware_destructive_interference_size)
      std::atomic<std::size_t> read_index_{0};
};
```

### Control-Loop Fallback Pattern

```cpp
auto maybe_action = queue.Pop();
if (!maybe_action.has_value()) {
  ExecuteSafetyFallbackHold();
} else {
  ExecuteActuatorCommand(maybe_action->joint_commands);
}
```

### Why This Is High-Signal

1. Uses bounded, preallocated storage (steady-state zero allocation).
2. Uses SPSC semantics with explicit acquire/release synchronization.
3. Avoids blocking primitives on the real-time thread.
4. Reduces cache-line contention via destructive-interference alignment.
5. Handles inference jitter by deterministic fallback instead of loop stall.

### Extension for True Buffer-Lifetime Ownership

For LiteRT external tensors or DMA-BUF handles, promote payload to a fixed-size slot table where each queue entry carries only a slot index and sequence number. The producer writes into slot N, then publishes N. The consumer reads slot N and returns ownership through a non-blocking free-list/token ring. This keeps metadata handoff lock-free while preserving zero-copy buffer reuse.

## Template for Additional Stored Answers

Use this template when adding new scenarios:

1. Problem summary with numeric constraints.
2. C++ answer with explicit memory model and ownership strategy.
3. Failure policy and fallback behavior.
4. L4 vs. L5 differentiation notes.
5. Validation plan (latency percentiles, missed-deadline count, thermal behavior, correctness parity).

## Scenario B: Zero-Copy Multi-Camera and IMU Ingestion

### Problem Summary

- Inputs: 3 cameras at 60 FPS and IMU at 1 kHz.
- Requirement: zero-copy steady state with bounded memory.
- Alignment policy: sensor bundle skew must stay within 2 ms.

### Production-Grade C++ Sample Answer (Ownership Skeleton)

```cpp
#include <array>
#include <atomic>
#include <cstdint>

struct DmaBufHandle {
  int fd{-1};
  std::uint32_t slot{0};
  std::uint64_t timestamp_ns{0};
};

struct SensorBundle {
  DmaBufHandle cam0;
  DmaBufHandle cam1;
  DmaBufHandle cam2;
  std::array<float, 12> imu_window{};
  std::uint64_t max_skew_ns{0};
  bool valid{false};
};

class SlotStateTable {
 public:
  static constexpr std::size_t kSlots = 8;
  enum class State : std::uint8_t { kFree, kProducerOwned, kReady, kConsumerOwned };

  bool TryAcquireProducerSlot(std::uint32_t& out) noexcept {
    for (std::uint32_t i = 0; i < kSlots; ++i) {
      State expected = State::kFree;
      if (states_[i].compare_exchange_strong(expected, State::kProducerOwned,
                                             std::memory_order_acq_rel)) {
        out = i;
        return true;
      }
    }
    return false;
  }

  void PublishReady(std::uint32_t i) noexcept {
    states_[i].store(State::kReady, std::memory_order_release);
  }

  bool TryAcquireConsumerSlot(std::uint32_t i) noexcept {
    State expected = State::kReady;
    return states_[i].compare_exchange_strong(expected, State::kConsumerOwned,
                                              std::memory_order_acq_rel);
  }

  void ReleaseToFree(std::uint32_t i) noexcept {
    states_[i].store(State::kFree, std::memory_order_release);
  }

 private:
  std::array<std::atomic<State>, kSlots> states_{};
};
```

### Backpressure and Freshness Policy

1. If producer cannot acquire free slot, drop oldest not-yet-consumed camera frame first.
2. Never block the control path waiting for aligned bundle formation.
3. Reject any bundle where max sensor skew exceeds 2 ms; emit metric and continue.

### L4 vs. L5 Signal

1. L4: bounded queues and correct timestamp checks.
2. L5: explicit slot-state machine, zero-copy lifetime contracts, and deterministic stale-data policy.

## Scenario C: ROS 2 Integration with Bounded Execution

### Problem Summary

- Control loop: 200 Hz hard periodic task.
- Learned inference: variable latency and best-effort.
- Requirement: avoid callback interference and priority inversion.

### Production-Grade Answer (Execution Model)

1. Use separate callback groups:
   - Mutually exclusive group for control-critical callbacks.
   - Reentrant group for inference and telemetry callbacks.
2. Run dedicated executors pinned to isolated CPU cores:
   - Real-time executor for control group only.
   - Best-effort executor for inference/logging.
3. Handoff between executors via lock-free SPSC queue carrying action tokens.
4. Control callback consumes latest action if age <= 20 ms; otherwise runs deterministic fallback.

### Minimal Fallback Gate

```cpp
if (latest_action_age_ns > 20ULL * 1000ULL * 1000ULL) {
  ExecuteSafetyFallbackHold();
} else {
  ExecuteActuatorCommand(latest.joint_commands);
}
```

### L4 vs. L5 Signal

1. L4: avoids blocking and separates callback groups.
2. L5: designs full executor topology, CPU affinity, and stale-data contracts with measurable deadlines.

## Scenario D: Quantization Regression After Conversion

### Problem Summary

- Regression: 12 percent drop in task success after INT8 conversion.
- Symptom: oscillation near contact events.
- Requirement: isolate numeric vs. runtime vs. control effects.

### Production-Grade Debugging and Gate Plan

1. Numerical parity stage:
   - Replay fixed dataset through FP32 and INT8 models.
   - Track layerwise cosine similarity, max error, and saturation counts.
2. Runtime stage:
   - Compare p50/p95/p99 inference latency and jitter under thermal load.
   - Trace delegate fallback ops and memory bandwidth pressure.
3. Closed-loop stage:
   - Run hardware-in-the-loop trials with identical seeds and trajectories.
   - Compare task success, contact stability, and safety-intervention rate.

### Ship/No-Ship Gates

1. Block release if task success drop exceeds 2 percent absolute.
2. Block release if missed-control-deadline rate increases above baseline + 0.1 percent.
3. Block release if safety fallback engagement rises above predefined envelope.

### L4 vs. L5 Signal

1. L4: proposes parity and task metrics.
2. L5: connects model conversion to physical-control failure signatures and defines enforceable rollout gates.

## Scenario E: Accelerator Reset and Runtime Recovery

### Problem Summary

- NPU delegate may reset during dynamic locomotion.
- Requirement: no control-thread stall, no corrupted model/runtime state.

### Production-Grade Recovery State Machine

```cpp
enum class RuntimeState : std::uint8_t {
  kReady,
  kDegradedFallback,
  kRebuildingDelegate,
  kRollback
};
```

1. On reset detection, atomically switch kReady -> kDegradedFallback.
2. Control thread immediately uses deterministic fallback controller.
3. Recovery worker rebuilds delegate and validates health checks out-of-band.
4. If rebuild completes within budget and parity checks pass, switch to kReady.
5. If rebuild exceeds budget or fails checks, switch to kRollback and keep fallback active.

### Observability Requirements

1. Emit counters: reset_count, rebuild_duration_ms, fallback_duration_ms.
2. Emit histogram for recovery time and deadline misses during degraded mode.
3. Record bounded event log for postmortem without blocking control path.

### L4 vs. L5 Signal

1. L4: handles reset and restarts delegate.
2. L5: introduces explicit state machine, bounded recovery budget, and safety-first rollback semantics.
