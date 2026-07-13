<!-- Personal practice copy. Source: docs/practice/questions/q19_deepmind-case-study-speculative-decoding-memory-locality-system.md -->

# Q19: DeepMind Case Study: Speculative Decoding Memory Locality System

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

During LiteRT-LM deployment, keeping a 1B draft model and an 8B primary model on distinct, isolated physical computing units (e.g., Draft on CPU, Primary on NPU) incurs high cross-bus token synchronization penalties. Design an architectural strategy that enforces memory locality to eliminate these stalls, detailing how memory addresses should be pinned.

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
