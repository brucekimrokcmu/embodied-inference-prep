#include <type_traits>

int main() {
    static_assert(std::is_abstract_v<Shape>);
    static_assert(std::has_virtual_destructor_v<Shape>);
}
