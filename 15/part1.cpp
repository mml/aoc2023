#include <iostream>
#include <fstream>
#include <string>
#include <cstring>

int64_t hash_until(char delim) {
  int64_t val = 0;
  char c;

  while (1) {
    // consider std::cin.get(c);
    std::cin >> c;
    if (std::cin.eof())
      break;
    if (c == delim)
      break;
    val += c;
    val *= 17;
    val %= 256;
  }

  return val;
}

int main(int argc, char* argv[]) {
  int64_t sum = 0;

  while (!std::cin.eof()) {
    sum += hash_until(',');
  }

  std::cout << sum << std::endl;
}
