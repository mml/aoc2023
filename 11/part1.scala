import scala.io.StdIn.readLine

type Loc = (Int,Int)
val empty = "^(\\.*)$".r

// Return a sequence of two rows (or columns) for each empty row...
// otherwise, a sequence of only one.
def doubleEmpty(rows: Seq[String]): Seq[String] =
  rows flatMap { row =>
    row match
    case empty(e) => Seq(e,e)
    case _ => Seq(row)
  }

object Image:
  var img = Seq.empty[String]

  def transposed =
    img.transpose map { _.mkString }

  def setTransposed(img_transposed: Seq[String] ) =
    img = img_transposed.transpose map { _.mkString }

  def expand =
    img = doubleEmpty(img)
    setTransposed(doubleEmpty(transposed))

  override def toString(): String =
    val sb = StringBuilder()
    img.foreach {
      sb ++= _.toString + "\n"
    }
    sb.toString

  def galaxies: List[Loc] =
    ((img map { _.zipWithIndex }).zipWithIndex.map{
      case (row,y) => row.map {
        case (ch,x) => if ch == '#' then Some((x,y)) else None
      }
    }).flatten.flatten.toList

def d(a: Loc, b: Loc): Int =
  (a._1 - b._1).abs + (a._2 - b._2).abs

def pairs(coords: List[Loc]): List[(Loc,Loc)] = coords match
  case Nil => List.empty[(Loc,Loc)]
  case hd :: tl => {
    var withHd: List[(Loc,Loc)] = tl map { (x:Loc) => (hd,x) }
    withHd ++ pairs(tl)
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
