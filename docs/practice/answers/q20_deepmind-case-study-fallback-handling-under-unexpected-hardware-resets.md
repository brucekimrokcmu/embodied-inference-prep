# Q20 Answer: DeepMind Case Study: Fallback Handling under Unexpected Hardware Resets

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

A robust runtime treats the accelerator as a backend that can become unhealthy. Each request should have a timeout and a clear failure state. When the NPU times out or resets, the runtime marks that backend unavailable, stops submitting new work to it, and routes compatible work to pre-initialized CPU kernels or a degraded model.

The control loop should not wait indefinitely for fallback. It should receive one of: a valid CPU result, the last known safe result, or an explicit safe-state signal. This keeps the robot control contract bounded even when inference quality degrades.

Recovery should be asynchronous. A background health manager can reset or reinitialize the NPU, warm up delegates, and re-enable the backend only after validation. The runtime should log failures and expose health state, but the hot path should remain simple: submit, timeout, fallback, or safe output.

```cpp
#include <iostream>
#include <vector>
#include <functional>

class ExecutionFallbackPipeline {
public:
    void ExecuteModelSafe(const std::vector<TensorBuffer>& inputs, std::vector<TensorBuffer>& outputs) {
        try {
            LiteRtStatus status = InvokeHardwareAccelerator(inputs, outputs);
            if (status != LiteRtStatus::kLiteRtStatusOk) {
                TriggerCpuReferenceFallback(inputs, outputs);
            }
        } catch (const std::exception& e) {
            std::cerr << "Hardware driver panic caught: " << e.what() << "\n";
            TriggerCpuReferenceFallback(inputs, outputs);
        }
    }

private:
    LiteRtStatus InvokeHardwareAccelerator(const std::vector<TensorBuffer>& inputs, std::vector<TensorBuffer>& outputs) {
        // Enforce a hard timeout threshold; return error code if driver stalls
        return LiteRtStatus::kLiteRtStatusError; // Mock failure condition
    }

    void TriggerCpuReferenceFallback(const std::vector<TensorBuffer>& inputs, std::vector<TensorBuffer>& outputs) {
        std::cout << "Switching execution to optimized CPU reference kernels via XNNPACK...\n";
        // Execute fallback matrix loops safely on isolated CPU threads
    }
};

```
