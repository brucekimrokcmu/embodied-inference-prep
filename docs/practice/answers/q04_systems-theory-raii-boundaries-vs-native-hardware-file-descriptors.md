# Q4 Answer: Systems Theory: RAII boundaries vs. Native Hardware File Descriptors

**Section:** Month 0: Core Systems Programming, Resource Stability, & DS/A (C++)

## Answer

RAII is the right user-space boundary for resources such as file descriptors, memory mappings, DMA handles, and device sessions. A wrapper owns the raw handle and releases it in the destructor. If a C++ exception is thrown and the stack unwinds normally, destructors for live objects run, so the wrapper can call `close`, `munmap`, or the matching release API.

That guarantee is not the same as surviving every crash. If the process is killed, aborts, or segfaults without normal unwinding, C++ destructors may not run. The kernel will close the process's file descriptors on exit, but physical device state may depend on the driver. Some drivers clean up per-file resources on close; others may require reset paths, watchdogs, or reopening/reinitialization by a supervisor process.

For a runtime engineer, the key design is to keep raw handles inside small move-only RAII types, make ownership explicit, and build recovery around process and driver behavior instead of assuming destructors solve hard crashes.

Under an RAII design pattern, the lifetime of a low-level operating system resource is bound directly to the lifecycle of a matching C++ object stack variable. When an resource object is created, it opens or acquires the resource handle within its constructor; when it goes out of scope, its destructor automatically releases it.
If an unhandled exception occurs while communicating with a device path like /dev/videoX, the runtime environment initiates stack unwinding, calling the destructors of all active stack objects in reverse order of creation. If the file descriptor handle is wrapped in a properly designed RAII class, the class destructor invokes the standard close() system call, releasing the file descriptor back to the kernel. If the handle is left exposed or lacks an RAII wrapper, the file descriptor remains open within the process table, leading to resource leaks that can block future initialization attempts until the application is restarted.
```cpp
#include <unistd.h>
#include <fcntl.h>
#include <stdexcept>

class HardwareDeviceHandler {
public:
    explicit HardwareDeviceHandler(const char* device_path) {
        fd_ = ::open(device_path, O_RDWR);
        if (fd_ < 0) {
            throw std::runtime_error("Failed to open hardware device path.");
        }
    }

    ~HardwareDeviceHandler() {
        if (fd_ >= 0) {
            ::close(fd_);
        }
    }

    // Disable copying to maintain strict single-ownership boundaries
    HardwareDeviceHandler(const HardwareDeviceHandler&) = delete;
    HardwareDeviceHandler& operator=(const HardwareDeviceHandler&) = delete;

private:
    int fd_ = -1;
};

```
