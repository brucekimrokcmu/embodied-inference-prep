<!-- Personal practice copy. Source: docs/practice/questions/q07_cpp-implementation-raii-guaranteed-thread-wrapper-with-explicit-core-affinity.md -->

# Q7: C++ Implementation: RAII-Guaranteed Thread Wrapper with Explicit Core Affinity

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

Write a production-level C++ structural wrapper for a real-time worker thread that guarantees safe execution join patterns via C++20 std::jthread. The constructor must accept a lambda payload and a target CPU core index, enforcing hardware isolation via low-level native thread handles (pthread_setaffinity_np) before executing the payload.

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
