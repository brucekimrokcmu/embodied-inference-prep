# Q8 Answer: C++ Implementation: Fast Custom Fixed-Size Queue for Matrix Stack Slicing

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

```cpp
#include <array>
#include <algorithm>
#include <stdexcept>

struct TargetClassification {
    int target_class_id;
    float confidence_score;
};

template<size_t K>
class StackFixedPriorityQueue {
public:
    StackFixedPriorityQueue() : active_elements_(0) {}

    void Push(int class_id, float score) {
        if (active_elements_ < K) {
            data_[active_elements_] = TargetClassification{class_id, score};
            active_elements_++;
            std::push_heap(data_.begin(), data_.begin() + active_elements_, MetricsComparator);
        } else if (score > data_[0].confidence_score) {
            std::pop_heap(data_.begin(), data_.begin() + active_elements_, MetricsComparator);
            data_[K - 1] = TargetClassification{class_id, score};
            std::push_heap(data_.begin(), data_.begin() + active_elements_, MetricsComparator);
        }
    }

    const std::array<TargetClassification, K>& GetRawData() const { return data_; }
    size_t Size() const { return active_elements_; }

private:
    static bool MetricsComparator(const TargetClassification& a, const TargetClassification& b) {
        return a.confidence_score > b.confidence_score; // Min-heap arrangement strategy
    }
    size_t active_elements_;
    std::array<TargetClassification, K> data_;
};

```
