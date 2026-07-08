# Q18 Answer: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Answer

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
