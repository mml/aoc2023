import scala.io.StdIn.readLine

type Loc = (Int,Int)
val emptyPat = "^(\\.*)$".r

def empty(row: String) =
  emptyPat.matches(row)

// This holds the input data (universe map), plus binds behavior.
// One thing I like about Scala is that it lets me create objects
// without the overhead of classes, which is often exactly the
// right amount of OO for these puzzle problems.
object Image:
  var img = Seq.empty[String]
  private var empty_rows = Seq.empty[Int]
  private var empty_cols = Seq.empty[Int]

  // These two methods allow us to re-use row-oriented logic to
  // operate on columns.  Very convenient!
  def transposed =
    img.transpose map { _.mkString }

  def setTransposed(img_transposed: Seq[String] ) =
    img = img_transposed.transpose map { _.mkString }

  // Locate empty rows and columns, so we can quickly calculate
  // expanded coordinates.
  def find_empties =
    empty_rows = img.zipWithIndex filter {
      case (row,ix) => empty(row)
    } map { _._2 }
    empty_cols = transposed.zipWithIndex filter {
      case (col,iy) => empty(col)
    } map { _._2 }

  def expanded_x(x: Long) =
    x + 999999 * (empty_cols filter { _ < x }).length

  def expanded_y(y: Long) =
    y + 999999 * (empty_rows filter { _ < y}).length

  def expanded(loc: Loc) =
    (expanded_x(loc._1), expanded_y(loc._2))

  override def toString() =
    var sb = StringBuilder()
    img.foreach { sb ++= _.toString + "\n" }
    sb.toString

  def galaxies: List[Loc] =
    // Use of zipWithIndex here could indicate that Vectors or Arrays
    // would have been better, but it does allow us to create something
    // like nested for loops.
    ((img map { _.zipWithIndex }).zipWithIndex.map{
      case (row,y) => row.map {
        case (ch,x) => if ch == '#' then Some((x,y)) else None
      }
    // The first flatten flattens out sublists.
    // The second one strips the Some/None.
    }).flatten.flatten.toList

// int64 (Long) is required here to represent the correct answer, which is
// above 2^39.  A 32-bit approach would have been to just count the "extra
// millions" separately
def d(a: Loc, b: Loc): Long =
  val ea = Image.expanded(a)
  val eb = Image.expanded(b)
  (ea._1 - eb._1).abs + (ea._2 - eb._2).abs

// Generates a list of all pairs of galaxies.
def pairs(coords: List[Loc]): List[(Loc,Loc)] = coords match
  case Nil => List.empty[(Loc,Loc)]
  case hd :: tl => {
    var withHd: List[(Loc,Loc)] = tl map { (x:Loc) => (hd,x) }
    withHd ++ pairs(tl)
  }

@main def main() =
  val buf = scala.collection.mutable.ListBuffer.empty[String]
  var line: String = ""
  while {
    line = readLine()
    line != null
  } do
    buf += line

  Image.img = buf.toList
  println(Image)
  Image.find_empties
  val g = Image.galaxies
  val p = pairs(g)
  //println(p)
  val ds = p map { case (a,b) => d(a,b) }
  //println(ds)
  println(ds.sum)
