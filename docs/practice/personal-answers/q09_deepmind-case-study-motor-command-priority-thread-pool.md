<!-- Personal practice copy. Source: docs/practice/questions/q09_deepmind-case-study-motor-command-priority-thread-pool.md -->

# Q9: DeepMind Case Study: Motor Command Priority Thread Pool

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

You are constructing an on-device task dispatcher for a humanoid robot. High-frequency joint torque computation tasks (1 kHz) must hit deadlines under 1 millisecond, while asynchronous vision-language-action (VLA) token generation results surface at irregular intervals. Detail the structural layout of a C++ scheduler that ensures low-priority ML scoring routines never cause latency spikes or priority inversion on real-time hardware threads.

## My Answer

_Write your answer here._

## My Comments

- 

## Scoring Rubric

Use 1 to 5 per category (1 = weak, 5 = excellent).

| Category | Interviewer Scoring (1-5) | Agentic-AI Scoring (1-5) | Self Scoring (1-5) |
|---|---:|---:|---:|
| Correctness |  |  |  |
| Depth |  |  |  |
| Systems Rigor |  |  |  |
| Latency and Performance Awareness |  |  |  |
| Clarity and Structure |  |  |  |

### Totals

| Total Type | Interviewer | Agentic-AI | Self |
|---|---:|---:|---:|
| Total Score (/25) |  |  |  |

### Gap Notes

- 
