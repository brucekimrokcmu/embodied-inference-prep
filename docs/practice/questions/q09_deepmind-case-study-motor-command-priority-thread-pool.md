# Q9: DeepMind Case Study: Motor Command Priority Thread Pool

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

You are constructing an on-device task dispatcher for a humanoid robot. High-frequency joint torque computation tasks (1 kHz) must hit deadlines under 1 millisecond, while asynchronous vision-language-action (VLA) token generation results surface at irregular intervals. Detail the structural layout of a C++ scheduler that ensures low-priority ML scoring routines never cause latency spikes or priority inversion on real-time hardware threads.

## Runtime Engineer Framing

Answer as a runtime scheduling problem, not an OS scheduler implementation. Focus on isolating real-time control work from best-effort inference work, bounding queues, avoiding shared locks in the control path, and defining drop/degrade behavior for late low-priority work.
