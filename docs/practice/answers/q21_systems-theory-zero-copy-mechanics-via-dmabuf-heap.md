# Q21 Answer: Systems Theory: Zero-Copy Mechanics via DMABUF Heap

**Section:** Month 2: Edge Framework Resource Utilization, Stability, & Power

## Answer

At user-space runtime level, DMABUF lets different device drivers refer to the same underlying buffer through a shared file descriptor. A camera path can allocate or export a frame buffer, the runtime passes the FD to an NPU or GPU API, and the receiving driver imports it without the runtime copying bytes through a separate CPU heap buffer.

The runtime still has responsibilities: choose the right heap or allocator, track FD lifetime with RAII, pass dimensions/strides/formats correctly, and synchronize producer/consumer access using fences or platform cache-sync APIs. Zero-copy avoids redundant `memcpy`, but it does not remove format conversion, synchronization, or backend constraints.

The practical benefit is lower latency and reduced memory bandwidth. On mobile/edge systems, large CPU copies of camera frames or tensors can increase bandwidth pressure, energy use, and thermal load. A careful answer should say "can increase power and latency" rather than assume a specific voltage drop without measurement.

The Linux DMABUF Heap infrastructure provides a file-descriptor-based way for user-space code and drivers to refer to shareable buffers. This lets a runtime pass a buffer handle between subsystems, such as camera capture and NPU input, instead of copying the underlying frame into a separate CPU-owned allocation.
If you use standard `memcpy` loops to move a high-resolution image buffer through extra intermediate buffers, the CPU must read and write every byte. This increases memory bandwidth pressure, power use, and latency. In a high-frequency robotics control loop, those copy delays can contribute to dropped frames or delayed motor commands.
