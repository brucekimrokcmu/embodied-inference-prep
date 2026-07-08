// Define a Counter class using Google-style class layout: public API first, 
// private data members last, and a trailing underscore for private data members. 
// Include a constructor, initializer list, Increment(), and int Value() const; 
// the validator calls Value() on a const Counter.


class Counter {
public:
    explicit Counter(int initial) 
    : value_(initial)
    {
    }

    void Increment() {
        ++value_;
    }

    int Value() const {
        return value_;
    }

private:
    int value_ = 0;
};
