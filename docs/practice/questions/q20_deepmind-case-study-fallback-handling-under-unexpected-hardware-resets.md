# Q20: DeepMind Case Study: Fallback Handling under Unexpected Hardware Resets

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

An on-device NPU running a vision-guided manipulation sub-graph encounters a hardware timeout or an unexpected driver-level reset. Design a robust, low-latency framework fallback architecture that instantly catches the dispatch failure and routes execution to a collection of optimized CPU reference kernels, preserving safety margins without missing a robot control tick.
