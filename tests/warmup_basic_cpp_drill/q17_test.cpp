#include <type_traits>

int main() {
    static_assert(std::is_abstract_v<Shape>);
}
