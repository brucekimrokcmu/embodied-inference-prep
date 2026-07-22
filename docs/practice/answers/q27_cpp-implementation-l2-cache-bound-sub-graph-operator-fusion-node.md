# Q27 Answer: C++ Implementation: L2-Cache Bound Sub-graph Operator Fusion Node

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Answer

A fused runtime node replaces two graph nodes with one execution unit when the intermediate tensor has no external users. Instead of writing convolution output to a full tensor and then reading it for activation, the node computes each output value, applies activation, and writes the final value once.

The runtime must preserve semantics: shapes, padding, strides, quantization parameters, and activation behavior must match the unfused graph. Fusion is valid only when no other node needs the unfused intermediate value.

The benefit is lower memory traffic and fewer allocations. The tradeoff is less modularity and more specialized kernels. A runtime engineer should fuse hot patterns that are common and measurable, while keeping fallback paths for unsupported shapes.

```cpp
#include <vector>
#include <cmath>

void FusedConvolutionAndHardSwish(const float* input, const float* weight, float* output, size_t size) {
    for (size_t i = 0; i < size; ++i) {
        // 1. Evaluate element-level convolution matrix math locally
        float intermediate_value = input[i] * weight[i];

        // 2. Pass the result directly to the activation function within active processor registers
        float native_clamp = std::min(std::max(intermediate_value + 3.0f, 0.0f), 6.0f);
        output[i] = intermediate_value * (native_clamp / 6.0f);

        // This avoids writing intermediate values back to external DRAM channels
    }
}

```
