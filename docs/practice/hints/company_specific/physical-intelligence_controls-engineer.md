# Physical Intelligence Hint Set: Controls Engineer

**Section:** Company-Specific Controls Interviews  
**Calibration:** L4-L5 controls engineer

Use these hints progressively. The goal is to guide candidates toward control design, first-principles debugging, model validation, and safe hardware bring-up.

## Hint 1: Control Stack Architecture

1. Separate learned-policy rate, planning/impedance rate, and actuator servo rate.
2. Learned outputs should become bounded references, not direct actuator commands.
3. Put the fastest safety checks closest to the actuator write.
4. Log measured state, reference, command before/after saturation, controller mode, safety flags, and timing.
5. Think in contracts: freshness, continuity, units, limits, and fallback behavior.

## Hint 2: PID and Feedforward

1. Overshoot can come from underdamping, latency, saturation, bad feedforward, friction, backlash, or incorrect payload/inertia.
2. Integral action helps steady-state error but can make saturation and contact behavior worse without anti-windup.
3. Derivative action amplifies measurement noise and can interact badly with encoder quantization or low-pass filters.
4. Feedforward reduces feedback burden when the model is good enough.
5. Tune at low speed/torque first, then increase envelope only after passing thresholds.

## Hint 3: LQR and MPC

1. Define state and input before talking about gains.
2. LQR is usually easier to run fast and reason about; MPC is useful when constraints dominate.
3. Discretization and latency matter as much as the continuous-time math.
4. MPC at 1 kHz is hard unless the problem is tiny, warm-started, and bounded.
5. Always describe stability, robustness margins, and fallback if the solver fails.

## Hint 4: Inverse Dynamics

1. Start with gravity compensation; it often exposes sign, mass, and frame errors quickly.
2. Track torque residuals: measured or estimated torque minus model-predicted torque.
3. Separate rigid-body model errors from friction, backlash, compliance, and current-limit effects.
4. Validate on slow trajectories before high-speed motion.
5. Near contact, model-based feedforward should be limited by contact safety and compliance.

## Hint 5: Contact and Impedance

1. Pure position control is often too stiff for insertion and contact-rich tasks.
2. Use lower stiffness along uncertain/contact axes and enough damping to avoid bounce.
3. Force/torque sensing helps, but motor current and position error can provide weaker contact signals.
4. Blend modes gradually; discontinuous stiffness changes can create impulses.
5. Exceeding contact force should trigger retract, replan, or degraded mode.

## Hint 6: Real-Time Loop

1. A 1 kHz loop gives only 1 ms; avoid allocation, blocking locks, I/O, and variable-time ML inference.
2. Loop order: read sensors, estimate state, sample command, safety check, compute control, saturate, write actuators, append telemetry.
3. If feedback is late, use a bounded prediction or hold policy, then degrade if lateness persists.
4. Deadline misses are control faults, not just software metrics.
5. Neural control belongs behind a stale-data and safety gate.

## Hint 7: Bring-Up

1. Verify units, signs, zero offsets, encoder direction, torque/current direction, and joint limits before closing the loop.
2. Start with motor disabled, then low-current open-loop checks, then low-gain closed-loop tests.
3. Every packet should have sequence, timestamp, status, and CRC/checksum when possible.
4. Bus faults need counters for drops, retries, late packets, error frames, and age at consume time.
5. Firmware telemetry should expose raw and calibrated values.

## Hint 8: Sim-to-Real

1. Compare traces, not only task success.
2. Inject measured latency, noise, quantization, saturation, friction, compliance, and packet loss into simulation.
3. If simulation needs impossible gains or no saturation to succeed, it is over-optimistic.
4. Use staged hardware trials: no payload, known payload, low speed, contact fixture, full task.
5. Keep datasets aligned by timestamp so research and controls can inspect the same episode.

## Interviewer Nudge Prompts

1. "What measurement would falsify your first hypothesis?"
2. "Where does saturation enter your controller?"
3. "What does your controller do if the MPC solver misses a deadline?"
4. "How do you know this is not a sign convention bug?"
5. "What is the first safe hardware test?"
6. "Which trace tells you simulation and hardware diverged?"
7. "What would make you stop the experiment immediately?"
