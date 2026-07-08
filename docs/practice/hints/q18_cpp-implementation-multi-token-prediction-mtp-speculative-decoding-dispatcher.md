# Q18 Hint: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

**Speculative Decoding Dispatcher:** The dispatcher must copy or point the generated token indices from the draft output back into the primary input template, updating sequence dimension flags before triggering parallel inference.
