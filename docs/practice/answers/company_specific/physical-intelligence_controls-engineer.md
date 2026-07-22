# Physical Intelligence Sample Answers: Controls Engineer

**Section:** Company-Specific Controls Interviews  
**Calibration:** Silicon Valley L4-L5 controls engineer

## Answer 1: Control Stack Architecture

I would use a layered stack:

- `policy_bridge`, 10 to 20 Hz: receives learned-policy Cartesian deltas, validates timestamps, clamps deltas, rejects discontinuities, and outputs high-level references.
- `trajectory_manager`, 100 to 250 Hz: creates smooth joint or Cartesian references with velocity, acceleration, jerk, workspace, and collision limits.
- `cartesian_controller`, 250 Hz: impedance or operational-space control for end-effector behavior.
- `joint_servo`, 1 kHz: joint feedback, feedforward, saturation, actuator command write, and fastest safety checks.
- `supervisor`: mode transitions, fault handling, enable/disable, and operator state.

Learned actions never directly command torque or current. They become bounded references with freshness and continuity checks. If an action is stale, discontinuous, infeasible, or unsafe, the controller holds the previous safe reference, executes a stop trajectory, or enters degraded mode depending on duration and severity.

Minimum logs: timestamps, reference and measured `q/qd`, Cartesian pose/error, commanded torque/current before and after saturation, controller mode, policy/action sequence, action age, tracking error, bus status, temperature, and fault bits.

## Answer 2: PID, Feedforward, and Disturbance Rejection

I would first identify the failure mode before changing gains.

Diagnosis:

- Step and chirp tests at low speed to estimate bandwidth, damping, phase lag, and resonance.
- Compare commanded torque/current against saturation limits.
- Inspect encoder velocity noise and filter delay.
- Run gravity-compensation hold tests at different postures.
- Check backlash/compliance by reversing direction slowly.
- Compare hardware trace to simulation using the same reference.

Controller improvements:

- If overshoot is underdamping, increase damping/velocity feedback or reduce proportional gain.
- If delay is dominant, reduce bandwidth and shorten filtering/communication latency.
- If steady-state error is gravity/friction, add gravity and friction feedforward before adding large integral gain.
- If saturation occurs, add anti-windup and reduce trajectory aggressiveness.
- If contact oscillates, reduce stiffness in contact axes and increase damping.

Derivative gain can worsen behavior because it amplifies encoder noise and interacts with low-pass filters, producing phase lag near crossover. Tuning should start at low torque/speed limits with E-stop active, soft travel limits, and automatic abort on excessive error/current/temperature.

Pass criteria: overshoot below target, for example < 2 deg; settling time within budget; no saturation except expected transients; tracking RMS improved; contact force peaks reduced; no new deadline misses or thermal regressions.

## Answer 3: LQR/MPC Controller Design

For fast joint-space stabilization, I would choose discrete LQR unless hard constraints dominate.

Example state:

```text
x = [q_error, qd_error]
u = joint torque correction
```

Model:

```text
x[k+1] = A x[k] + B u[k]
```

The cost penalizes position error, velocity error, and control effort:

```text
J = sum x'Qx + u'Ru
```

I would linearize around operating points or use gain scheduling for large posture changes. The discrete controller must include sample time and estimated delay. Validation includes eigenvalue checks, step responses, disturbance rejection tests, saturation tests, and hardware trials at reduced limits.

MPC is preferred when constraints are central: torque limits, velocity limits, contact force limits, obstacle constraints, or mobile-base nonholonomic constraints. MPC is risky at 1 kHz if solve time is variable, warm-starts are unreliable, constraints are nonconvex, or solver failure lacks a deterministic fallback. In practice, MPC may run at 50 to 250 Hz while a lower-level servo runs at 1 kHz.

## Answer 4: Inverse Dynamics and Model Validation

The feedforward model should include:

```text
tau = M(q) qdd + C(q, qd) qd + g(q) + tau_friction(qd) + tau_payload
```

It also needs motor constants, gear ratios, current limits, torque limits, joint limits, and actuator dynamics.

Validation plan:

1. Verify signs, units, joint zeros, link frames, and gravity direction.
2. Run slow gravity-compensation holds across the workspace.
3. Identify friction with low-speed positive/negative velocity sweeps.
4. Run known trajectories and compare predicted torque to measured current-derived torque.
5. Fit residual models only after rigid-body parameters are correct.

Bad gravity compensation shows posture-dependent steady torque error even at rest. Bad friction modeling shows velocity-direction-dependent residuals and stick-slip near zero velocity. The model is good enough for higher speed when residuals stay bounded across representative payloads and trajectories, tracking improves versus PD-only, and saturation/safety intervention rates do not regress.

Near contact, inverse dynamics should not blindly push through mismatch. It should be combined with impedance or force limits.

## Answer 5: Contact-Rich Manipulation and Impedance Control

For insertion, I would use Cartesian impedance or admittance depending on actuator interface and sensing. With torque control, impedance is natural:

```text
F_cmd = Kx (x_ref - x) + Dx (xd_ref - xd) + F_ff
tau_cmd = J(q)' F_cmd + tau_nullspace + tau_gravity
```

Tuning:

- High stiffness along the insertion axis only if alignment is trusted.
- Lower lateral stiffness to allow compliance against fixture errors.
- Damping near critical damping to reduce bounce.
- Force thresholds to detect hard contact or jamming.
- Smooth blending from free-space to contact mode to avoid discontinuous force commands.

If force exceeds threshold, stop insertion, retract slightly, reduce stiffness, search/retry, or fail safely. Without a wrist force/torque sensor, use motor current residuals, joint torque estimates, tracking error, and end-effector motion residuals as weaker contact indicators.

## Answer 6: Real-Time Loop Implementation

At 1 kHz, the loop must be bounded:

```cpp
void JointServoTick(uint64_t now_ns) {
  JointFeedback fb = ReadActuatorFeedback();
  StateEstimate x = EstimateState(fb);
  Reference ref = reference_buffer.SampleOrHold(now_ns);

  FaultBits faults = SafetyPreCheck(x, ref);
  if (faults.hard_fault) {
    WriteSafeTorqueOffOrHold();
    LogRt(now_ns, x, ref, {}, faults);
    return;
  }

  TorqueCmd tau = Controller(x, ref);
  TorqueCmd limited = ApplyLimitsAndRateLimits(tau);
  faults |= SafetyPostCheck(x, ref, limited);

  WriteActuators(limited);
  LogRt(now_ns, x, ref, limited, faults);
}
```

Rules: no heap allocation, no filesystem or network I/O, no blocking locks, no unbounded solver, no waiting for neural inference. Neural outputs are consumed only after being converted to safe references by a lower-rate bridge.

Example 1 ms budget:

- bus feedback read/decode: 150 us
- state estimate and filters: 100 us
- reference sample and safety precheck: 100 us
- controller and inverse dynamics: 250 us
- saturation and packet encode: 100 us
- actuator write: 150 us
- telemetry append: 25 us
- jitter margin: 125 us

If feedback arrives late for one tick, hold or predict for one bounded step and flag degraded timing. If lateness persists, execute controlled stop.

## Answer 7: Actuator, Sensor, and Bus Bring-Up

Bring-up should be staged:

1. Offline review: electrical limits, pinout, bus termination, firmware version, packet format, units, signs, CRC, watchdog behavior.
2. Motor disabled: read raw encoder/current/temperature/status and verify timestamps and sequence numbers.
3. Low-current open-loop: verify torque/current direction, motor phase wiring, encoder direction, and joint sign.
4. Low-gain closed-loop: small moves with soft limits and physical clearance.
5. Full subsystem: bandwidth, step response, thermal, bus load, packet drop, and fault injection.
6. Robot integration: reduced speed, known payload, then task-level validation.

Required firmware telemetry: raw encoder, calibrated position, velocity, current, voltage, temperature, fault bits, packet sequence, device timestamp, control mode, saturation flags, bus error counters, watchdog resets, and command age.

Diagnosis examples:

- Wrong sign: positive command causes negative measured motion or unstable immediate divergence.
- Bad encoder scaling: motion direction correct but magnitude wrong.
- Bus latency: command and feedback age spikes correlate with tracking error.
- Motor phase issue: poor torque, high current, heating, rough motion.

## Answer 8: Simulation-to-Hardware Transfer

I would compare simulation and hardware using aligned traces, not just task success.

Calibrate:

- link masses/inertia/COM.
- payload mass/inertia.
- joint friction and stiction.
- actuator torque/current limits.
- sensor noise and quantization.
- communication and filtering latency.
- compliance/backlash.
- contact/friction parameters.

Simulation should inject measured latency, noise, saturation, packet drops, and actuator limits. Before hardware, run unit tests, controller stability tests, Monte Carlo parameter sweeps, fault injection, and low-speed replay of planned trajectories.

If simulation predicts low tracking error while hardware shows high error, inspect residuals by stage: model torque residual, command saturation, sensor delay, contact residual, and bus age. Change the controller if the design is fragile under realistic uncertainty; change the model/simulator if traces diverge before controller limits; inspect hardware if faults correlate with temperature, posture, wiring, or specific actuator modules.

## Answer 9: First-Principles Debugging Case

For wrist oscillation only with a heavy payload, my hypotheses are:

- payload mass/inertia missing or wrong in gravity/inverse dynamics.
- wrist torque/current saturation.
- structural compliance or resonance excited by the payload.
- velocity filter delay reducing phase margin.
- thermal/current limiting under sustained load.
- loose mechanical coupling or encoder issue.

I would reduce risk first: lower speed/torque limits, use a known test payload, keep clear of humans/fixtures, and add abort thresholds for current, error, and temperature.

Data to collect: posture, payload, measured/reference `q/qd`, commanded and measured current, saturation flags, estimated torque residual, filter state, bus age, temperature, contact state, and frequency content of the oscillation.

A quick experiment to separate instability from saturation: hold the same posture with reduced controller gains and compare commanded torque/current against limits. If oscillation disappears when bandwidth is reduced and no saturation occurs, phase margin/resonance is likely. If command is pegged at torque/current limits while error remains, the actuator is underpowered or the model/payload estimate is wrong.

Stop immediately on growing oscillation amplitude, hard-limit approach, unexpected encoder jump, repeated bus timeout, excessive current/temperature, or contact force above threshold.

## Scoring Rubric

L4 pass:

- Designs layered control loops with appropriate rates and safety gates.
- Diagnoses PID/feedforward issues beyond simple gain changes.
- Can formulate practical LQR/MPC and explain real-time tradeoffs.
- Builds a reasonable inverse-dynamics validation plan.
- Defines safe actuator/sensor bring-up and hardware test thresholds.

L5 pass:

- Connects control performance to hardware limits, firmware, bus timing, sensors, payloads, contact, and learned-policy interfaces.
- Uses residuals, trace comparison, and first-principles hypotheses to debug complex behavior.
- Designs safe degradation and recovery, not just nominal controllers.
- Builds sim-to-real workflows that deliberately include uncertainty and measured runtime effects.
- Communicates clear contracts and datasets across research, hardware, firmware, operations, and controls.

No-hire / major concern:

- Responds to most failures by blindly tuning PID.
- Ignores saturation, delay, filtering, bus faults, payload variation, or model mismatch.
- Lets learned-policy output bypass safety and feasibility gates.
- Cannot describe safe hardware bring-up.
- Provides no numeric pass/fail criteria or abort thresholds.
