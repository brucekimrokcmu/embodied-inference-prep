// Demonstrate why a polymorphic base needs a virtual destructor. Define a
// DestructionState with base_destroyed and derived_destroyed flags. Define Base,
// constructed from DestructionState&, whose virtual destructor sets the base
// flag. Publicly derive Derived and have its destructor set the derived flag.
// Explain why deleting a Derived through Base* requires the virtual destructor.
