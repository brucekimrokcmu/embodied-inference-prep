# Q17 Answer: C++ Implementation: Dynamic Tensor Lifetime Tracking Node

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

Tensor lifetime tracking is a memory reuse problem. Each intermediate buffer is produced by one operation and consumed by one or more later operations. Once the last consumer has run, the runtime can recycle that memory.

A simple runtime design stores operators in topological order and precomputes a use count for each tensor. During execution, an op reads its input buffers and writes its outputs. After the op completes, the runtime decrements use counts for the inputs. Any input whose count reaches zero is returned to a buffer pool.

Reference-counting wrappers can model this, but in a performance-sensitive runtime static use counts are often cheaper. The key is to avoid freeing memory back to the OS in the hot path; recycle it within the runtime's planned pool.

```cpp
#include <vector>
#include <memory>
#include <unordered_map>

class TrackingTensorBuffer {
public:
    explicit TrackingTensorBuffer(size_t size) : size_(size), reference_counter_(0) {
        raw_allocation_ = std::make_unique<float[]>(size_);
    }
    void IncrementReference() { reference_counter_++; }
    void DecrementReference() {
        if (--reference_counter_ == 0) {
            raw_allocation_.reset(); // Immediate resource reclamation point
        }
    }
    float* GetRawData() { return raw_allocation_.get(); }
private:
    size_t size_;
    int reference_counter_;
    std::unique_ptr<float[]> raw_allocation_;
};

class ExecutionGraphLifetimeTracker {
public:
    void ExecuteNode(const std::vector<int>& input_ids, const std::vector<int>& output_ids) {
        // Track allocations and immediately release intermediate buffers after their last read
        for (int in_id : input_ids) {
            if (active_tensors_.count(in_id)) {
                active_tensors_[in_id]->DecrementReference();
            }
        }
    }
private:
    std::unordered_map<int, std::shared_ptr<TrackingTensorBuffer>> active_tensors_;
};

```
