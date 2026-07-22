# Q29 Hint: DeepMind Case Study: Thermal-Aware Multi-Model Orchestration Engine

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Hint

Separate critical and degradable workloads. Gait control may need strict deadlines; vision quality or frequency may be reducible. Use thermal state as an input to scheduling policy, not as an afterthought.

**Thermal Coordination Engine:** Create an executive control thread that polls /sys/class/thermal/. When temperatures hit predefined warning levels, adjust your control loops by lowering frame ingestion rates or routing tasks away from the NPU.
