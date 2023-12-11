//> using toolkit latest

import scala.io.StdIn.readLine
import scala.util.matching.Regex

def doubleEmpty(rows: Seq[String]): Seq[String] = {
  val empty: Regex = "^(\\.*)$".r
  rows flatMap { row =>
    row match
    case empty(e) => Seq(e,e)
    case _ => Seq(row)
  }
}

def empty(row: String) = {
  val empty: Regex = "^(\\.*)$".r
  empty.matches(row)
}

object Image:
  var img: Seq[String] = null
  var empty_rows: Seq[Int] = null
  var empty_cols: Seq[Int] = null

  def ymax =
    img.length-1

  def xmax =
    img.map({_.length}).max

  def transposed =
    img.transpose map { _.mkString }

  def setTransposed(img_transposed: Seq[String] ) =
    img = img_transposed.transpose map { _.mkString }

  def expand: Unit = {
    img = doubleEmpty(img)
    setTransposed(doubleEmpty(transposed))
  }

  def find_empties: Unit = {
    empty_rows = img.zipWithIndex filter {
      case (row,ix) => empty(row)
    } map { _._2 }
    empty_cols = transposed.zipWithIndex filter {
      case (col,iy) => empty(col)
    } map { _._2 }
  }

  def expanded_x(x: BigInt) =
    x + BigInt(999999) * (empty_cols filter { _ < x }).length

  def expanded_y(y: BigInt) =
    y + BigInt(999999) * (empty_rows filter { _ < y}).length

  override def toString(): String =
    var sb = StringBuilder()
    img.foreach {
      sb ++= _.toString + "\n"
    }
    sb.toString

  def galaxies: List[(Int,Int)] =
    ((img map { _.zipWithIndex }).zipWithIndex.map{
      case (row,y) => row.map {
        case (ch,x) => if ch == '#' then Some((x,y)) else None
      }
    }).flatten.flatten.toList

def d(a: (Int,Int), b: (Int,Int)): BigInt =
  ((Image.expanded_x(a._1) - Image.expanded_x(b._1)).abs
    +
    (Image.expanded_y(a._2) - Image.expanded_y(b._2)).abs)

def pairs(coords: List[(Int,Int)]): List[((Int,Int),(Int,Int))] = coords match {
  case Nil => List.empty[((Int,Int),(Int,Int))]
  case hd :: tl => {
    var withHd: List[((Int,Int),(Int,Int))] = tl map { (x:(Int,Int)) => (hd,x) }
    withHd ++ pairs(tl)
  }
}

@main def main() =
  val buf = scala.collection.mutable.ListBuffer.empty[String]
  var line: String = null
  while {
    line = readLine()
    line != null
  } do {
    buf += line
  }
  Image.img = buf.toList

  println(Image)
  println("----------------------------------------")
  //Image.expand
  Image.find_empties
  println(Image)
  val g = Image.galaxies
  val p = pairs(g)
  println(p)
  val ds = p map { case (a,b) => d(a,b) }
  println(ds)
  println(ds.sum)
