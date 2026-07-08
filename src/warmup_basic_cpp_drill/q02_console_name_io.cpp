// Read a user's name from std::cin and print hello, <name>.

#include <iostream>
#include <string>

int main() {
    std::string name;
    std::cout << "Enter your name: ";

    std::getline(std::cin, name);

    std::cout << "hello, " << name << std::endl;
    
    return 0;
}