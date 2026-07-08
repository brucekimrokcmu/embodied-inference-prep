# Q17 Answer: C++ Implementation: Dynamic Tensor Lifetime Tracking Node

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

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
