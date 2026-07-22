# Q16 Answer: C++ Implementation: Asynchronous Model Execution Layer via CompiledModel

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

An async model wrapper should make submitted work explicit. A call creates an in-flight request containing input buffer references, output destinations, a completion event or future, and timeout/cancellation metadata. The primary loop submits work and continues; it does not block unless it chooses to wait for a result.

The runtime must define buffer lifetime. Inputs must remain valid until the backend has consumed them. Outputs must not be read until the completion event fires. If zero-copy buffers are used, ownership and synchronization must be even clearer.

The wrapper should also handle failures: accelerator timeout, cancellation, invalid input shape, or fallback routing. The important engineering property is bounded coordination overhead and clear state transitions: pending, running, complete, failed, or canceled.

```cpp
#include <vector>
#include <functional>
#include <future>
#include <memory>

class MockEvent {
public:
    void Wait() { future_trigger_.wait(); }
    void SignalComplete() { promise_trigger_.set_value(); }
private:
    std::promise<void> promise_trigger_;
    std::shared_future<void> future_trigger_ = promise_trigger_.get_future();
};

class MockCompiledModel {
public:
    void RunAsync(const std::vector<TensorBuffer>& inputs, std::vector<TensorBuffer>& outputs, MockEvent* comp_event) {
        // Emulate true non-blocking low-latency asynchronous worker evaluation
        std::thread([inputs, outputs, comp_event]() mutable {
            // Underneath, this layer communicates with NPU hardware execution contexts
            for (size_t i = 0; i < inputs.size() && i < outputs.size(); ++i) {
                for (size_t k = 0; k < inputs[i].element_count; ++k) {
                    outputs[i].data_ptr[k] = inputs[i].data_ptr[k] * 2.0f; // Mock operation
                }
            }
            comp_event->SignalComplete();
        }).detach();
    }
};

```
