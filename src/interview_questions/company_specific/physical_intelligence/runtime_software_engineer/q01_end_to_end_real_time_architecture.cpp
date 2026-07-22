/*
### Question 1: End-to-End Real-Time Architecture

Design the runtime architecture from sensor capture to actuator write.

Be explicit about:

- Which threads/processes exist and what each owns.
- Which threads run with real-time priority.
- CPU affinity and isolation strategy.
- Which queues/buffers exist between stages.
- What work is forbidden on the control thread.
- How timestamps and sequence numbers propagate across the system.

Follow-up:

- What changes if the inference worker sometimes takes 80 ms?
- How do you keep debug logging from perturbing the 5 ms control period?
- Where would you draw the boundary between middleware and custom runtime code?
*/


/* 

    End-to-end runtime architecture

Sensors / Drivers
  +---------------------------------------------------------+
  │  RGB_Camera_0  ──────┐                                  │
  │  RGB_Camera_1  ──────┼──> [ Vision / Policy ] <--┐      │ (~60 Hz / Asynchronous)
  │  Depth_Camera_0 ─────┘         │                 |      │  Outputs: High-level targets
  │                                │ (Target States) |      │
  │                                v                 |      │
  │  IMU ───────────────┐   [ Control Loop ]         |      │ (200 Hz / Strict 5 ms)
  │  Joint Encoders ────┴──────>   │                 |      │  Outputs: Low-level Torques
  +---------------------|----------|-----------------|------+
                        v          |                 |
            [State Estimator]------|-----------------┘
               (EKF / 1 kHz)       v
                      [ Actuators / Motor Drivers ]    (1–20 kHz FOC Loop)
                                   │
                                   v
                           Physical Movement


*/

/*
Threads/processes





*/