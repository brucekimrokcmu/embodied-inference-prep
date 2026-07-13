<!-- Personal practice copy. Source: docs/practice/questions/q02_systems-theory-atomic-memory-orderings.md -->

# Q2: Systems Theory: Atomic Memory Orderings

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Question

A real-time thread reads state vectors from a lock-free queue using std::memory_order_relaxed, while a background inference worker pushes updates using std::memory_order_relaxed. Explain why this code might crash or read stale pointers on an ARM-based robotics SoC, and describe the exact combination of memory_order flags required to establish a proper values-release relationship.

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
