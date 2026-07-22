# Physical Intelligence Controls Engineer: Real-World Robot Control

**Section:** Company-Specific Controls Interviews  
**Calibration:** Silicon Valley L4-L5 controls engineer  
**Format:** 60-minute technical interview plus optional 30-minute deep dive

## Interview Scenario

You are joining the Controls team for a robot manipulation platform that combines learned policies with classical control. Researchers provide target motions, learned action deltas, and task success metrics. Your team owns the real-time controllers, models, actuator/sensor bring-up, simulation validation, tuning workflow, and hardware debugging needed to make the robot behave smoothly and safely.

The current prototype can complete tasks in controlled demos, but behavior is inconsistent:

- The arm oscillates near contact.
- Some trajectories look smooth in simulation but overshoot on hardware.
- Learned-policy actions occasionally excite actuator limits.
- A CAN-connected actuator chain sometimes drops status frames.
- Operators need a structured way to diagnose whether failures are caused by model error, controller tuning, actuator saturation, sensor noise, communication latency, or hardware defects.

Assume this simplified platform:

- 7-DOF torque-controlled arm with gripper
- Joint control loop: 1 kHz
- Whole-arm Cartesian impedance loop: 250 Hz
- Learned policy action rate: 10 to 20 Hz
- Actuator network: CAN-FD or EtherCAT-like bus
- Sensors: joint encoders, motor current, optional wrist force/torque sensor, cameras
- Control targets: joint trajectories, end-effector poses, Cartesian deltas, contact-rich manipulation primitives
- Safety constraints: joint limits, velocity/torque limits, temperature limits, collision/contact thresholds, E-stop

Hard requirements:

- Real-time control loops must remain deterministic under learned-policy and operator inputs.
- Controllers must degrade safely when sensors, actuators, or communication become unreliable.
- Simulation validation must predict hardware behavior well enough to reduce risky trial-and-error tuning.
- Debugging must use first-principles reasoning and structured data, not only gain guessing.

## Candidate Deliverables

1. Control architecture from learned/operator targets to actuator commands.
2. Controller choices for free-space motion, contact, and disturbance rejection.
3. Model identification and validation plan.
4. Real-time loop design with deterministic timing and safety gates.
5. Actuator/sensor bring-up and communication fault plan.
6. Simulation-to-hardware transfer strategy.
7. Debugging workflow for oscillation, overshoot, tracking error, and bus faults.
8. Release criteria with numeric pass/fail thresholds.

## Main Interview Questions

### Question 1: Control Stack Architecture

Design the control stack for a 7-DOF manipulation arm that receives learned-policy Cartesian deltas at 10 to 20 Hz and must drive actuators at 1 kHz.

Be explicit about:

- Which loops run at 1 kHz, 250 Hz, and 10 to 20 Hz.
- Where trajectory generation, impedance control, inverse dynamics, and safety checks live.
- How learned-policy output is filtered or gated before entering control.
- What happens when the learned policy produces stale, discontinuous, or infeasible commands.
- What data you log for controller tuning and postmortem analysis.

Follow-up:

- What belongs in joint space versus Cartesian space?
- How do you prevent a low-rate learned policy from creating high-frequency actuator commands?

### Question 2: PID, Feedforward, and Disturbance Rejection

You observe 8 deg overshoot on a fast joint move and a 4 Hz oscillation when the gripper contacts an object.

Design a diagnosis and controller improvement plan.

Be explicit about:

- How you distinguish underdamping, delay, friction, backlash, saturation, sensor filtering, and incorrect inertia estimates.
- How you would tune PID terms safely.
- When you would add velocity, acceleration, gravity, friction, or inverse-dynamics feedforward.
- How anti-windup and saturation handling should work.
- What tests prove the change improved behavior.

Follow-up:

- Why can increasing derivative gain make behavior worse on real hardware?
- How do you tune without damaging the robot?

### Question 3: LQR/MPC Controller Design

Pick either LQR or MPC for a subsystem such as joint-space stabilization, mobile-base velocity control, or Cartesian end-effector tracking.

Be explicit about:

- State definition.
- Control input definition.
- Model assumptions.
- Cost function or objective.
- Constraints.
- Linearization or discretization.
- Real-time feasibility.
- How you validate stability and robustness.

Follow-up:

- When is LQR the better engineering choice than MPC?
- What makes an MPC design unsafe or impractical for a 1 kHz loop?

### Question 4: Inverse Dynamics and Model Validation

You need to add model-based feedforward to improve tracking on a 7-DOF arm.

Be explicit about:

- What model terms you need: mass matrix, Coriolis/centrifugal, gravity, friction, motor constants, gear ratios, actuator limits.
- How you would identify or calibrate uncertain parameters.
- How you validate the model in simulation and on hardware.
- What residuals you track.
- How you handle model mismatch near contact.

Follow-up:

- What failure signatures suggest bad gravity compensation versus bad friction modeling?
- How do you decide the model is good enough to enable higher-speed motion?

### Question 5: Contact-Rich Manipulation and Impedance Control

The robot must insert a part into a fixture. Pure position control succeeds in simulation but fails on hardware because small pose errors cause large contact forces.

Design a contact-aware controller.

Be explicit about:

- Cartesian impedance/admittance control choice.
- Stiffness and damping selection.
- Force/torque sensor use, if available.
- Contact detection and force limits.
- How to blend free-space motion into contact mode.
- Recovery when insertion force exceeds threshold.

Follow-up:

- How do you tune stiffness differently along insertion and lateral axes?
- What do you do if there is no wrist force/torque sensor?

### Question 6: Real-Time Loop Implementation

Implement the runtime control loop structure for the arm.

Be explicit about:

- Loop ordering at 1 kHz.
- Sensor read, state estimation, command sampling, control law, saturation, actuator write, and telemetry.
- Memory allocation and locking rules.
- Deadline monitoring and overrun behavior.
- Numeric safety checks.
- How neural-network-driven control is isolated from the hard real-time loop.

Follow-up:

- What is your per-stage budget inside a 1 ms cycle?
- What happens if actuator feedback arrives late for one tick?

### Question 7: Actuator, Sensor, and Bus Bring-Up

You are bringing up a new actuator module connected over CAN-FD, SPI, I2C, or Ethernet.

Design the bring-up and validation plan.

Be explicit about:

- Driver/interface contract.
- Units, signs, calibration, and timestamp conventions.
- Command and feedback packet validation.
- Bus timing, jitter, retries, and timeout policy.
- Electrical/mechanical sanity checks.
- Incremental enable sequence from bench to full robot.

Follow-up:

- How do you diagnose whether a control issue is bus latency, bad encoder scaling, motor phase wiring, or wrong joint sign?
- What telemetry do you require from firmware?

### Question 8: Simulation-to-Hardware Transfer

A controller passes simulation but fails on hardware with high tracking error and intermittent contact instability.

Design a sim-to-real validation workflow.

Be explicit about:

- What physics parameters need calibration.
- How to compare sim and hardware traces.
- How to inject latency, noise, quantization, saturation, and communication drops into simulation.
- Which tests run before hardware trials.
- How you decide whether to change the controller, model, simulator, or hardware.

Follow-up:

- What metrics reveal that simulation is over-optimistic?
- How do you structure datasets for researchers and controls engineers to debug together?

### Question 9: First-Principles Debugging Case

During a manipulation run, the wrist begins oscillating only when holding a heavy object at a specific arm posture. The issue is not reproduced with an empty gripper.

Walk through your debugging process.

Be explicit about:

- Hypotheses ordered by likelihood and safety risk.
- Data you collect.
- Tests you run with reduced risk.
- How payload inertia, gravity compensation, current limits, thermal limits, sensor filtering, and structural compliance could contribute.
- How you communicate findings and next steps to hardware, research, and operations.

Follow-up:

- What quick experiment would separate controller instability from actuator torque saturation?
- What would make you stop testing immediately?

## Interviewer Calibration

Strong L4 signal:

- Can design a layered real-time control architecture.
- Understands PID/feedforward tuning, saturation, anti-windup, and sensor filtering tradeoffs.
- Can formulate LQR/MPC at a practical level.
- Uses model validation and trace comparison rather than ad hoc tuning.
- Defines safe hardware bring-up steps and concrete pass/fail thresholds.

Strong L5 signal:

- Connects control behavior to hardware, firmware, communication, timing, model mismatch, and learned-policy interfaces.
- Designs controllers and validation workflows that degrade safely under uncertainty.
- Can reason from first principles about oscillation, contact instability, actuator limits, and payload changes.
- Defines cross-functional debugging artifacts useful to researchers, hardware engineers, firmware engineers, and operators.
- Quantifies stability, robustness, timing, and release gates.

Weak signals:

- Treats every problem as "tune PID gains" without diagnosis.
- Ignores saturation, latency, sensor filtering, actuator limits, or communication faults.
- Trusts simulation without hardware residuals or uncertainty injection.
- Allows learned-policy outputs to directly command actuators.
- Provides no safe bring-up process or numeric validation criteria.
