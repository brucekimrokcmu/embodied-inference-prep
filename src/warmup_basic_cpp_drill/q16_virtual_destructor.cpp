// Demonstrate why a polymorphic base needs a virtual destructor. Define a
// DestructionState with base_destroyed and derived_destroyed flags. Define Base,
// constructed from DestructionState&, whose virtual destructor sets the base
// flag. Publicly derive Derived and have its destructor set the derived flag.
// Explain why deleting a Derived through Base* requires the virtual destructor.

struct DestructionState {
    bool base_destroyed = false;
    bool derived_destroyed = false;
};

class Base {
public:
    explicit Base(DestructionState& state) : state_(state) {}
    virtual ~Base() {
        state_.base_destroyed = true;
    };

protected:
    DestructionState& state_;
};

class Derived : public Base {
public: 
    explicit Derived(DestructionState& state) : Base(state) {} 
    ~Derived() override {
        state_.derived_destroyed = true;
    }
};
