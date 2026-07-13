<!-- Personal practice copy. Source: docs/practice/questions/q18_cpp-implementation-multi-token-prediction-mtp-speculative-decoding-dispatcher.md -->

# Q18: C++ Implementation: Multi-Token Prediction (MTP) Speculative Decoding Dispatcher

**Section:** Month 1: LiteRT & LiteRT-LM Framework Internals (Core, Dispatch, & Trade-offs)

## Question

Implement a structural C++ manager class that coordinates speculative decoding for LiteRT-LM. The class must manage two distinct CompiledModel targets: a small "draft" model and a larger primary model. It must dispatch the draft model to generate K candidate tokens sequentially, and then feed the complete token sequence into the primary model for parallel validation in a single execution step.

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
