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

var m map[string]*Mapt

func mapnum(m *Mapt, x uint32) uint32 {
  for ; m != nil; m = m.next {
    if m.min <= x && x <= m.max {
      if (m.delta >= 0) {
        return x + uint32(m.delta)
      } else {
        return x - uint32(-m.delta)
      }
    }
  }
  return x
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
      //fmt.Printf("seeds -> %v\n", seedlist)
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
    //fmt.Printf("%q %v <= x <= %v --> x+%v\n", curmap, nums[1], nums[1]+nums[2]-1, int32(nums[0]-nums[1]))
    mm := Mapt{nums[1], nums[1]+nums[2]-1,int32(nums[0]-nums[1]),nil}
    if curtail == nil {
      m[curmap] = &mm
    } else {
      curtail.next = &mm
    }
    curtail = &mm
  }

  minx := ^uint32(0)
  for _, seed := range seedlist {
    x := seed
    //fmt.Printf("seed %v, ", seed)
    x = mapnum(m["seed-to-soil"], x)
    //fmt.Printf("soil %v, ", x)
    x = mapnum(m["soil-to-fertilizer"], x)
    //fmt.Printf("fertilizer %v, ", x)
    x = mapnum(m["fertilizer-to-water"], x)
    //fmt.Printf("water %v, ", x)
    x = mapnum(m["water-to-light"], x)
    //fmt.Printf("light %v, ", x)
    x = mapnum(m["light-to-temperature"], x)
    //fmt.Printf("temperature %v, ", x)
    x = mapnum(m["temperature-to-humidity"], x)
    //fmt.Printf("humidity %v, ", x)
    x = mapnum(m["humidity-to-location"], x)
    //fmt.Printf("location %v\n", x)
    //fmt.Println("--")
    if (x < minx) {
      minx = x
    }
  }

  fmt.Println(minx)
}
