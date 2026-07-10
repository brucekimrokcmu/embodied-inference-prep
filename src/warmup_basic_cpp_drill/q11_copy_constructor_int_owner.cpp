// Write a copy constructor for a simple class that owns an int*. 
// Use Google-style class layout and avoid public data members.

class IntOwner {
public:
    explicit IntOwner(int val) : val_(new int(val)) {}

    IntOwner(const IntOwner& other) {
        if (other.val_ != nullptr) {
            val_ = new int(*other.val_);
        } else {
            val_ = nullptr;
        }
    }

    IntOwner& operator=(const IntOwner& other) {
        if (this != &other) {
            delete val_;
            
            if (other.val_ != nullptr) {
                val_ = new int(*other.val_);
            } else {
                val_ = nullptr;
            }
        }
        return *this;
    }

    ~IntOwner() {
        delete val_;
        val_ = nullptr;
    }

private:
    int* val_;
};
