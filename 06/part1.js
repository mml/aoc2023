#!/usr/bin/env node

// times = [7,15,30]
// records = [9,40,200]
// times = [44, 89, 96, 91]
// records = [277, 1136, 1890, 1768]

// part 2
// times = [71530]
// records = [940200]
times = [44899691]
records = [277113618901768]

prod = 1
for (var i = 0; i < times.length; i++) {
  ways = 0
  for (hold = 1; hold < times[i]; hold++) {
    if (hold*(times[i]-hold) > records[i]) {
      ways++
    }
  }
  prod *= ways
}
console.log(prod)
