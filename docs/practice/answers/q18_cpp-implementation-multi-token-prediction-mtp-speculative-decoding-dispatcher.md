# Q18 Answer: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

Speculative decoding is a runtime pipeline. A small draft model proposes several candidate tokens quickly. The primary model then validates those candidates, accepting a prefix and rejecting the rest if probabilities disagree.

The manager should keep proposed tokens in a staging buffer. It should not permanently mutate visible session state or primary KV-cache state until validation completes. Accepted tokens are committed; rejected tokens are discarded and normal decoding resumes from the last accepted state.

The practical runtime concerns are scheduling and memory ownership. Draft and primary models may run on different backends, but token buffers, KV-cache pages, and completion events must be coordinated. The design should make rollback cheap and explicit.

```cpp
#include <vector>
#include <memory>

class SpeculativeDecodingManager {
public:
    SpeculativeDecodingManager(std::unique_ptr<MockCompiledModel> draft, std::unique_ptr<MockCompiledModel> primary)
        : draft_model_(std::move(draft)), primary_model_(std::move(primary)) {}

    void RunSpeculativeInferenceStep(const std::vector<TensorBuffer>& prompt_input, std::vector<TensorBuffer>& final_outputs) {
        std::vector<TensorBuffer> draft_candidate_tokens;

        // 1. Generate K candidate tokens sequentially using the small draft model
        for (int k = 0; k < 4; ++k) {
            MockEvent step_event;
            draft_model_->RunAsync(prompt_input, draft_candidate_tokens, &step_event);
            step_event.Wait();
            // Append token results to generation sequences...
        }

        // 2. Validate the complete sequence in parallel using the primary model
        MockEvent validation_event;
        primary_model_->RunAsync(draft_candidate_tokens, final_outputs, &validation_event);
        validation_event.Wait();
    }

private:
    std::unique_ptr<MockCompiledModel> draft_model_;
    std::unique_ptr<MockCompiledModel> primary_model_;
};

```
