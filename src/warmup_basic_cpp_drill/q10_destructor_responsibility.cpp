// Write a Google-style RAII class ScopedFlag that stores a bool&, 
// sets it to true in the constructor, and resets it to false in the destructor. 
// Delete copy construction and move assignment.

class ScopedFlag {
public:
    explicit ScopedFlag(bool& flag)
    : flag_(flag) 
    {
        flag_ = true;
    }

    ~ScopedFlag() {
        flag_ = false;
    }

    ScopedFlag(const ScopedFlag&) = delete;
    ScopedFlag& operator=(const ScopedFlag&) = delete;

private:
    bool& flag_;
};