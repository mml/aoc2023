//> using toolkit latest

import scala.io.StdIn.readLine
import scala.util.matching.Regex
// import java.io.{FileInputStream, File, InputStream}

/*
object Kitty:
  private val buf = new Array[Byte](4096) // not super efficient yo
  private var cnt: Int = 0

  def copyStream(stream: InputStream): Unit =
    while {
      cnt = stream.read(buf)
      cnt != -1
    } do
      System.out.write(buf, 0, cnt)
*/

def doubleEmpty(rows: Seq[String]): Seq[String] = {
  val empty: Regex = "^(\\.*)$".r
  rows flatMap { row =>
    row match
    case empty(e) => Seq(e,e)
    case _ => Seq(row)
  }
}

object Image:
  var img: Seq[String] = null

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

def d(a: (Int,Int), b: (Int,Int)): Int =
  (a._1 - b._1).abs + (a._2 - b._2).abs

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
  Image.expand
  println(Image)
  val g = Image.galaxies
  val p = pairs(g)
  println(p)
  val ds = p map { case (a,b) => d(a,b) }
  println(ds)
  println(ds.sum)
