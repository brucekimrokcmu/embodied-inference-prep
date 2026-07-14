#include <cassert>
#include <type_traits>

int main() {
    static_assert(std::is_base_of_v<Shape, Circle>);
    static_assert(std::is_convertible_v<Circle*, Shape*>);
    static_assert(!std::has_virtual_destructor_v<Shape>);

    const Circle circle(2.5);
    assert(circle.radius() == 2.5);
}
