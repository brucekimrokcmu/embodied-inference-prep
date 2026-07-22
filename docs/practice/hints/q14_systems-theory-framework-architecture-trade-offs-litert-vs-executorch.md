# Q14 Hint: Systems Theory: Framework Architecture Trade-offs (LiteRT vs. ExecuTorch)

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Hint

Avoid brand trivia. Compare runtime properties: when memory is planned, how dynamic shapes are handled, how backends are selected, how much work is done ahead of time, and what happens when an accelerator cannot run part of the graph.

**LiteRT vs. ExecuTorch:** Consider flexibility versus predictability. ExecuTorch creates an unchangeable memory map ahead of time, which works wonderfully on tiny microcontroller systems but makes it difficult to adjust for dynamic sequences without planning for absolute worst-case scenario buffer sizes.
