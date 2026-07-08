# Q29: DeepMind Case Study: Thermal-Aware Multi-Model Orchestration Engine

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Question

A quadruped robot relies on three models: an omnidirectional vision network, a localization filter, and a gait control model. During long-duration missions, the NPU temperature hits critical limits, inducing hardware throttling. Design an adaptable C++ coordination engine that modifies inference rate limits, scales down model dimensions, or redistributes operations across the CPU/GPU to maintain stability within strict thermal envelopes.
