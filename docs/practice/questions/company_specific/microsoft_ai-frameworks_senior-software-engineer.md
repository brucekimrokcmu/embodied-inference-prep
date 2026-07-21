# Microsoft AI Frameworks: Senior Software Engineer (Company-Specific Question Set)

**Section:** Company-Specific Runtime and AI Infrastructure Interviews

## Question 1: Cross-Device Runtime Contract for Model Execution

You are designing a runtime abstraction that executes the same model graph across CPU, GPU, and NPU backends on cloud and edge devices. Device capabilities differ (operator coverage, memory limits, precision support). Propose a backend-dispatch contract that preserves correctness while maximizing throughput.

Address:
- Capability discovery and kernel selection.
- Fallback behavior when an operator is unsupported.
- How you avoid hidden numerical regressions across backends.
- What ABI/API boundaries you lock to keep the platform evolvable.

## Question 2: Performance Regression in Large-Scale Inference Fleet

A new runtime release improves median latency by 8% but worsens p99 by 35% in one region. Throughput is high, but tail latency violates SLOs for interactive copilots.

Design an investigation and mitigation plan that spans scheduler behavior, batching policy, memory pressure, and transport/network effects. Include the first metrics and traces you would inspect and how you decide rollback vs partial rollout.

## Question 3: Memory Planning for Dynamic Shapes and Multi-Tenant Workloads

You need a memory planner for transformer-style models with dynamic sequence lengths and concurrent tenant requests. The existing allocator causes fragmentation and occasional OOM despite free memory still being available in small chunks.

Describe a planner strategy that improves reuse and predictability while balancing utilization and latency. Include admission control or guardrails if needed.

## Question 4: Reliability Engineering for Runtime Upgrades

Your team ships monthly runtime upgrades used by multiple model teams. A previous release introduced a silent accuracy regression on one hardware family.

Propose a release-gating and observability strategy for framework-level changes that catches both numerical and performance regressions early. Specify what tests run pre-merge, pre-release, and canary phases.
