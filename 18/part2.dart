import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

// This class was initially created because I was trying to "sort the points in
// clockwise order", which routinely gave me the wrong results vs using the
// points in the arbitrary order they arrived in.
class Corner implements Comparable<Corner> {
  double angle;
  int x;
  int y;

  Corner(this.x, this.y) 
      : angle = atan2(y, x);

  @override
  int compareTo(Corner other) {
    return angle.compareTo(other.angle);
  }

  @override
  String toString() {
    return "($x,$y)@$angle";
  }
}

int twiceTrapezoidArea((Corner, Corner) pair) {
  final (p0, p1) = pair;
  return (p0.y + p1.y) * (p0.x - p1.x);
}

int twiceTriangleArea((Corner, Corner) pair) {
  final (p0, p1) = pair;
  return (p0.x * p1.y) - (p1.x * p0.y);
}

class Polygon {
  // SplayTreeSet acts as an ordered list with the extra irrelevant (for our
  // porpoises) property that items only appear once in it.
  //SplayTreeSet<Corner> corners = SplayTreeSet<Corner>();
  List<Corner> corners = [];

  void addCorner(int x, int y) {
    corners.add(Corner(x, y));
  }

  Iterable<(Corner,Corner)> cornerPairs() sync* {
    var it = corners.iterator;
    if (! it.moveNext()) { return; } // Nothing in it.
    Corner first = it.current;
    Corner prev = first;
    while (it.moveNext()) {
      yield (prev, it.current);
      prev = it.current;
    }
    yield (prev, first); // Because shoelace algorithms need that last Pn,P0 pair
  }

  // I experimented with two different formulations of the area.
  int twiceArea() {
    return cornerPairs()
      .map(twiceTrapezoidArea)
      .reduce((a,b) => a+b)
      .abs();
  }

  int triangleArea() {
    int twiceArea = cornerPairs()
      .map(twiceTriangleArea)
      .reduce((a,b) => a+b);
    
    if (twiceArea % 2 == 1) {
      print("A*2=$twiceArea is odd.");
      exit(1);
    }
    return (twiceArea/2).toInt();
  }

  int trapezoidArea() {
    int twiceArea = cornerPairs()
      .map(twiceTrapezoidArea)
      .reduce((a,b) => a+b);
    
    if (twiceArea % 2 == 1) {
      print("A*2=$twiceArea is odd.");
      exit(1);
    }
    return (twiceArea/2).toInt();
  }

  @override
  String toString() {
    return corners.toString();
  }
}

void main(List<String> arguments) {
  doStdin();
}

void doStdin() {
  int border = 1;
  Polygon p = Polygon.new();
  int x = 0;
  int y = 0;
  p.addCorner(x,y);
  while (true) {
    String? line = stdin.readLineSync();

    if (line == null) {
      break;
    }

    final splitted = line.split(' ');
    final inst = splitted[2];
    final dist = inst.substring(2, 7);
    final dir = inst.substring(7, 8);
    print("dist=$dist dir=$dir");
    int dx = 0;
    int dy = 0;
    switch (dir) {
      case "0": //"R":
        dx = 1;
      case "2": //"L":
        dx = -1;
      case "3": //"U":
        dy = 1;
      case "1": //"D":
        dy = -1;
      default:
        exit(64);
    }
    var n = int.parse(dist, radix: 16);
    border += n;
    print("n=$n");
    dx *= n;
    dy *= n;
    x += dx;
    y += dy;
    p.addCorner(x, y);
  }
  // Pick's theorem, solved for i, plus the border.
  // When you rearrange, you get this formulation.
  var volume = (p.twiceArea() + border) / 2 + 1;
  // Note that there is still a small bug here Strangely, I always get an
  // answer that's 0.5 greater than the correct answer.
  print(volume);
  exit(0);
}
