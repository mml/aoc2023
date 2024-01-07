import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

class Grid {
  static const q1 = 0;
  static const q2 = 1;
  static const q3 = 2;
  static const q4 = 3;
  static const dirs = [[0,1],[1,0],[0,-1],[-1,0]];

  List<List<List<int>>> v = [[], [], [], []];
  int ymin = 0;
  int ymax = 0;
  int xmin = 0;
  int xmax = 0;

  int quad(int x, int y) {
    if (y >= 0) {
      if (x >= 0) {
        return q1;
      }
      return q2;
    }
    if (x >= 0) {
      return q4;
    }
    return q3;
  }

  void set(int x, int y) {
    int q = quad(x,y);
    int ax = x.abs();
    int ay = y.abs();

    if (x < xmin) {
      xmin = x;
    }
    if (x > xmax) {
      xmax = x;
    }
    if (y < ymin) {
      ymin = y;
    }
    if (y > ymax) {
      ymax = y;
    }
    while (v[q].length <= ax) {
      v[q].add([]);
    }
    while (v[q][ax].length <= ay) {
      v[q][ax].add(0);
    }
    v[q][ax][ay] = 1;
  }

  int get(int x, int y) {
    int q = quad(x,y);
    int ax = x.abs();
    int ay = y.abs();

    if (ax >= v[q].length) {
      return 0;
    }
    if (ay >= v[q][ax].length) {
      return 0;
    }
    return v[q][ax][ay];
  }

  void printIt() {
    for (var y = ymax; y >= ymin; y--) {
      printRow(y);
    }
  }

  void printRow(y) {
    for (var x = xmin; x <= xmax; ++x) {
      if (get(x, y) == 1) {
        stdout.write("#");
      } else {
        stdout.write(".");
      }
    }
    stdout.write("\n");
  }

  (int, int) findInside() {
    for (var x = xmin; x <= xmax; x++) {
      for (var y = ymin; y <= ymax; y++) {
        var v = get(x,y);
        print("findInside...($x,$y)=$v");
        if (get(x,y) == 1) {
          if (get(x,y+1) == 1) {
            if (get(x+1,y+1) == 1) {
              exit(99);
            }
            return (x+1,y+1);
          } else {
            return (x,y+1);
          }
        }
      }
    }
    return (0,0);
  }

  void fill(int x, int y) {
    var q = [(x,y)];
    /*
    var v = get(x,y);
    print("fill($x,$y)");
    print("get($x,$y)=$v");
    */
    while (q.length > 0) {
      final (xx,yy) = q.removeAt(0);
      print("fill($xx,$yy)");
      if (! inside(xx, yy)) {
        continue;
      }
      set(xx, yy);
      for (var dir in dirs) {
        final xdx = xx+dir[0];
        final ydy = yy+dir[1];
        print("check ($xdx,$ydy)");
        if (xmin <= xdx && xdx <= xmax && ymin <= ydy && ydy <= ymax) {
          q.add((xdx,ydy));
        }
      }
    }
  }

  bool inside(int x, int y) {
    return get(x, y) == 0;
  }

  int sum() {
    int s = 0;

    for (final q in [q1,q2,q3,q4]) {
      s += v[q]
            .map((l) => l.fold(0, (a,b) => a+b))
            .fold(0, (a,b) => a+b);
    }
    return s;
  }
}

void main(List<String> arguments) {
  doStdin();
}

void doStdin() {
  Grid g = Grid.new();
  int x = 0;
  int y = 0;
  g.set(x,y);
  while (true) {
    String? line = stdin.readLineSync();

    if (line == null) {
      break;
    }

    final splitted = line.split(' ');
    print(splitted);
    int dx = 0;
    int dy = 0;
    switch (splitted[0]) {
      case "R":
        dx = 1;
      case "L":
        dx = -1;
      case "U":
        dy = 1;
      case "D":
        dy = -1;
    }
    var n = int.parse(splitted[1]);
    for (var i = 0; i < n; i++) {
      x += dx;
      y += dy;
      print("($x,$y)");
      g.set(x,y);
    }
  }
  g.printIt();

  var (x0,y0) = g.findInside();
  print("fill($x0,$y0)");
  g.fill(x0,y0);
  g.printIt();
  int sum = g.sum();
  print("\nsum = $sum");
}
