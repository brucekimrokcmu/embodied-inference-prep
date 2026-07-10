// Show a small example where a friend function can read a private field in a Google-style class.

#include <string>

class NoSecret {
public:
    friend std::string RevealPassword(const NoSecret& obj);

private:
    const std::string password_ = "samsung";

};

std::string RevealPassword(const NoSecret& obj) {
    return obj.password_;
}

int main() {
    NoSecret obj;
    RevealPassword(obj);

    return 0;
}
