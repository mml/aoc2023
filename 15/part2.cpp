#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <list>
#include <cstdint>

typedef std::pair<std::string,int32_t> ent;
typedef std::list<ent> entlist;

static entlist hm[256];

void remove(int64_t box, std::string key) {
  char c;

  std::cin >> c;

  for (auto it = hm[box].begin(); it != hm[box].end(); ) {
    if ((*it).first == key) {
      it = hm[box].erase(it);
    }  else {
      ++it;
    }
  }
}

void update(int64_t box, std::string key) {
  int64_t val = 0;
  char c;

  while (1) {
    std::cin >> c;
    if (std::cin.eof())
      break;
    if (c == ',')
      break;
    val *= 10;
    val += c-'0';
  }

  for (auto it = hm[box].begin(); it != hm[box].end(); ) {
    if (it->first == key) {
      it->second = val;
      return;
    }  else {
      ++it;
    }
  }

  hm[box].push_back(std::pair(key,val));
}

void read_step() {
  int64_t box = 0;
  std::string key = "";
  char c;

  while (1) {
    // consider std::cin.get(c);
    std::cin >> c;
    if (std::cin.eof())
      break;
    switch (c) {
      case '=':
        return update(box, key);
        break;
      case '-':
        return remove(box, key);
        break;
      default:
        key += c;
        box += c;
        box *= 17;
        box %= 256;
    }
  }
}

int64_t total() {
  int64_t sum = 0;

  for (uint64_t i = 0; i < 256; ++i) {
    // std::cout << "Box " << i << ": ";
    int64_t j = 1;
    for (const auto& it : hm[i]) {
      // std::cout << "[" << it.first << " " << it.second << "] ";
      sum += (i+1)*(j++)*(it.second);
    }
    // std::cout << std::endl;
  }

  return sum;
}


int main(int argc, char* argv[]) {
  while (!std::cin.eof()) {
    read_step();
  }

  std::cout << total() << std::endl;
}
