#include <cassert>
#include <type_traits>

int main() {
    static_assert(!std::is_copy_constructible_v<ScopedFlag>);
    static_assert(!std::is_copy_assignable_v<ScopedFlag>);

    bool flag = false;
    {
        ScopedFlag scoped_flag(flag);
        assert(flag);
    }
    assert(!flag);
}
