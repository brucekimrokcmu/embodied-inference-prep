# Q18 Hint: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

At runtime level, track accepted tokens separately from proposed tokens. Draft generation can run ahead, but the primary model owns correctness. Think about what state must be committed only after validation: output tokens, KV cache pages, and visible session state.

**Speculative Decoding Dispatcher:** The dispatcher must copy or point the generated token indices from the draft output back into the primary input template, updating sequence dimension flags before triggering parallel inference.
