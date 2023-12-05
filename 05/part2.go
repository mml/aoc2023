package main
import (
  "bufio"
  "regexp"
  "fmt"
  "os"
  "strings"
  "strconv"
)

type Mapt struct {
  min uint32
  max uint32
  delta int32
  next *Mapt
}

func (m *Mapt) contains(x uint32) bool {
  return m.min <= x && x <= m.max
}

type Range struct {
  lo uint32
  hi uint32
  next *Range
}

func (r *Range) String() string {
  if r.next == nil {
    return fmt.Sprintf("[%d,%d]", r.lo, r.hi)
  } else {
    return fmt.Sprintf("[%d,%d]->%s", r.lo, r.hi, r.next.String())
  }
}

func (r0 *Range) min() (ret uint32) {
  ret = ^uint32(0)
  for r := r0; r != nil; r = r.next {
    if r.lo < ret {
      ret = r.lo
    }
  }
  return
}

var m map[string]*Mapt

func (m0 *Mapt) mapnum(x uint32) uint32 {
  for m := m0 ; m != nil; m = m.next {
    if m.contains(x) {
      if (m.delta >= 0) {
        return x + uint32(m.delta)
      } else {
        return x - uint32(-m.delta)
      }
    }
  }
  return x
}

func maprange(m0 *Mapt, r0 *Range) {
  for r := r0; r != nil; r = r.next {
    for m := m0; m != nil; m = m.next {
      if m.contains(r.lo) {
        if m.contains(r.hi) {
          break
        } else {
          // (lo:max, recur[max+1:hi])
          rr := Range{m.max+1, r.hi, r.next}
          r.hi = m.max
          r.next = &rr
          break
        }
      } else if m.contains(r.hi) {
        // (recur[lo:min-1],min:hi)
        rr := Range{r.lo, m.min-1, r.next}
        r.lo = m.min
        r.next = &rr
        break
      }
    }
    r.lo = m0.mapnum(r.lo)
    r.hi = m0.mapnum(r.hi)
  }
}

func splitInts(s string) []uint32 {
  l := make([]uint32,0)
  for _, seed := range strings.Split(s, " ") {
    parsed, err := strconv.ParseUint(seed, 10, 32)
    if err != nil {
      fmt.Errorf("oh no", err)
    }
    l = append(l, uint32(parsed))
  }
  return l
}

func main() {
  var seedlist []uint32
  m = make(map[string]*Mapt)
  seedsRe := regexp.MustCompile(`^seeds: (\d.*)`)
  mapRe := regexp.MustCompile(`(\S+) map:`)
  sepRe := regexp.MustCompile(`^\s*$`)
  curmap := ""
  var curtail *Mapt = nil
  scanner := bufio.NewScanner(os.Stdin)
  for scanner.Scan() {
    ln := scanner.Text()
    seeds := seedsRe.FindStringSubmatch(ln)
    if seeds != nil {
      seedlist = splitInts(seeds[1])
      continue
    }
    mapp := mapRe.FindStringSubmatch(ln)
    if mapp != nil {
      curmap = mapp[1]
      curtail = nil
      continue
    }
    if sepRe.MatchString(ln) {
      continue
    }
    nums := splitInts(ln)
    mm := Mapt{nums[1], nums[1]+nums[2]-1,int32(nums[0]-nums[1]),nil}
    if curtail == nil {
      m[curmap] = &mm
    } else {
      curtail.next = &mm
    }
    curtail = &mm
  }

  minx := ^uint32(0)
  for i := 0; i < len(seedlist); i+= 2 {
    r := &Range{seedlist[i], seedlist[i]+seedlist[i+1]-1, nil}
    fmt.Printf("range %v, ", r)
    maprange(m["seed-to-soil"], r)
    fmt.Printf("soil %v, ", r)
    maprange(m["soil-to-fertilizer"], r)
    fmt.Printf("fertilizer %v, ", r)
    maprange(m["fertilizer-to-water"], r)
    fmt.Printf("water %v, ", r)
    maprange(m["water-to-light"], r)
    fmt.Printf("light %v, ", r)
    maprange(m["light-to-temperature"], r)
    fmt.Printf("temperature %v, ", r)
    maprange(m["temperature-to-humidity"], r)
    fmt.Printf("humidity %v, ", r)
    maprange(m["humidity-to-location"], r)
    fmt.Printf("location %v", r)
    fmt.Printf("\n")
    if rmin := r.min(); rmin < minx {
      minx = rmin
    }
  }
  fmt.Println(minx)
}
