#include <cassert>
#include <type_traits>

int main() {
    static_assert(std::is_base_of_v<Base, Derived>);
    static_assert(std::has_virtual_destructor_v<Base>);

    DestructionState state;
    Base* object = new Derived(state);
    delete object;

    assert(state.derived_destroyed);
    assert(state.base_destroyed);
}
