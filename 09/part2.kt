import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.util.Scanner

fun d(l: ArrayList<Int>): ArrayList<Int> {
  val dl = ArrayList<Int>()
  for (i in 1..l.count()-1) {
    dl.add(l[i]-l[i-1])
  }
  return dl
}

fun zeros(l: ArrayList<Int>): Boolean {
  for (i in l) {
    if (i != 0) {
      return false
    }
  }
  return true
}

fun next(l: ArrayList<Int>): Int {
  if (zeros(l)) {
    return 0
  } else {
    return l.last() + next(d(l))
  }
}

fun prev(l: ArrayList<Int>): Int {
  if (zeros(l)) {
    return 0
  } else {
    return l.first() - prev(d(l))
  }
}

fun main() {
  var sum = 0
  while (true) {
    try {
      var line = readln()
      var s = Scanner(line)
      val ns = ArrayList<Int>()
      while (s.hasNextInt()) {
          ns.add(s.nextInt())
      }
      println(ns)
      // println("->" + next(ns))
      sum += prev(ns)
    } catch (e: Exception) {
      println(e)
      break
    }
  }
  println(sum)
}
