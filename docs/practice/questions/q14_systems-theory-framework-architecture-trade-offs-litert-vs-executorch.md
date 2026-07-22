# Q14: Systems Theory: Framework Architecture Trade-offs (LiteRT vs. ExecuTorch)

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Compare the core design principles of Google’s LiteRT against Meta's ExecuTorch. Detail the structural differences regarding runtime memory planning (dynamic multi-backend fallbacks vs. static, ahead-of-time baked program schemas) and evaluate how these design tracks impact execution when parsing models with dynamic token lengths.

## Runtime Engineer Framing

Frame the comparison around deployment tradeoffs an edge runtime engineer must choose: startup cost, binary size, model format, static versus dynamic shapes, backend fallback, memory planning, and how much flexibility is needed after the model ships.
