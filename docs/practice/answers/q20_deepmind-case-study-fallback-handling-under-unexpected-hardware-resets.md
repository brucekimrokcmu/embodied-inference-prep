# Q20 Answer: DeepMind Case Study: Fallback Handling under Unexpected Hardware Resets

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

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
