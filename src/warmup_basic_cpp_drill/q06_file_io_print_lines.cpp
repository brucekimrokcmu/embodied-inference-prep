// Open a text file with std::ifstream and print each line.

#include <iostream>
#include <fstream>
#include <string>


int main() {
    std::ifstream file("test_file.txt");

    if (!file.is_open()) {
        std::cerr << "Error: Could not open the file" << std::endl;
        return 1;
    }

    std::string line;
    while(std::getline(file, line)) {
        std::cout << line << '\n';
    }

    return 0;
}