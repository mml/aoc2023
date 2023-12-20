#!/usr/bin/env raku

use v6.d;

class Node {
  has Int $.x;
  has Int $.y;
}

class ListGraph {
  has %!edges = ();

  method add-vertex($name) {
    %!edges{$name} = [];
  }

  method add-edge($u, $v, $weight) {
    %!edges{$u}.push({v => $v, w => $weight});
  }

  method neighbors($u) {
    flat %!edges{$u};
  }

  method enumerate-vertices { %!edges.keys }
}

class Neighbors does Iterator {
  has $.mat is required;
  has $.x is required;
  has $.y is required;
  has @.d is required;
  has $.weight is rw = 0;
  has $.index is rw = 0;
  method pull-one {
    return IterationEnd if $.index >= @.d.elems;
    my $x2 = $.x + @.d[$.index;0];
    my $y2 = $.y + @.d[$.index;1];
    ++$.index;

    return IterationEnd unless $.mat[$x2;$y2]:exists;
    $.weight += $.mat[$x2;$y2];
    return $x2, $y2, $.weight;
  }
}

class After does Iterator {
  has $.first is required;
  has $.rest is required;
  has $.in_first is rw = True;
  method pull-one {
    if $.in_first {
      my $v = $.first.pull-one;
      return $v unless $v =:= IterationEnd;
      $.in_first = False;
    }
    return $.rest.pull-one;
  }
}

# This represents the matrix of "nodes with weights" that we get as input.
# We'll use this to construct the two sets of vertices and the weighted edges
# between them all.
class Matrix does Positional {
  has Int $.width;
  has Int $.height;
  has @!vals is built;

  submethod BUILD(:$!width, :$!height) {
    @!vals = [[Inf xx $!width] xx $!height];
  }

  method parse-row(Str $str, Int $y) {
    my $x = 0;
    for $str.match(rx/./, :exhaustive) -> $c {
      @!vals[$y;$x++] = $c.Int;
    }
  }

  method to-graph {
    my $g = self.init-graph;
    self.add-edges($g);
    return $g;
  }

  method vertex-name(Int $x, Int $y, Str $dir) {
    return "[$x,$y]-$dir";
  }

  # Creates a graph with all the vertices and with special "start" and "finish"
  # nodes connected via 0-weight edges, but no other edges.
  method init-graph {
    #my $num_vertices = 2 + 2 * self.elems;
    my $g = ListGraph.new;
    #say "Created graph of size $num_vertices";

    $g.add-vertex("start");
    $g.add-vertex("finish");

    for 0..$.width-1 -> $y {
      for 0..$.height-1 -> $x {
        $g.add-vertex(self.vertex-name($x, $y, "V"));
        $g.add-vertex(self.vertex-name($x, $y, "H"));
      }
    }

    $g.add-edge("start", self.vertex-name(0, 0, "V"), 0);
    $g.add-edge("start", self.vertex-name(0, 0, "H"), 0);
    $g.add-edge(self.vertex-name($.height-1, $.width-1, "V"), "finish", 0);
    $g.add-edge(self.vertex-name($.height-1, $.width-1, "H"), "finish", 0);

    return $g;
  }

  method add-edges($g) {
    for self.iter_coords -> [$x, $y] {
      my $hv = self.vertex-name($x, $y, 'H');
      my $vv = self.vertex-name($x, $y, 'V');
      for self.h-neighbors($x, $y) -> $nx, $ny, $w {
        my $nhv = self.vertex-name($nx, $ny, 'H');
        $g.add-edge($vv, $nhv, $w);
      }
      for self.v-neighbors($x, $y) -> $nx, $ny, $w {
        my $nvv = self.vertex-name($nx, $ny, 'V');
        $g.add-edge($hv, $nvv, $w);
      }
    }
  }

  method gist { "Matrix(:width => $.width, :height => $.height)" }
  method Str {
    my $rv = "Matrix([\n";
    for @!vals -> $row {
      $rv ~= join(" ", $row);
      $rv ~= "\n";
    }
    $rv ~= "])\n";
    return $rv;
  }
  method vals() { @!vals }
  method coords(Int $idx) {
    my $y = $idx div $!width;
    my $x = $idx mod $!width;

    return ($x, $y);
  }

  method elems() { $.width * $.height }
  multi method AT-POS(Int $idx) {
    my ($x, $y) = self.coords($idx);
    @!vals[$y;$x];
  }
  multi method AT-POS(Int $x, Int $y) { @!vals[$y;$x] }
  method EXISTS-POS(Int $x, Int $y) {
    ($x >= 0 & $y >= 0 & @!vals.EXISTS-POS($y,$x))
  }
  method exists(Int $x, Int $y) {
    0 <= $x and $x < $!width and 0 <= $y and $y < $!height;
  }
  method iter_coords {
    gather {
      for 0..$!width-1 -> $x {
        for 0..$!height-1 -> $y {
          take [$x, $y];
        }
      }
    }
  }
  method neighbors-and-weights(Int $x, Int $y, @d) {
    gather {
      my $weight = 0;
      for @d -> [$dx, $dy] {
        my $x2 = $x + $dx;
        my $y2 = $y + $dy;
        if self.exists($x2,$y2) {
          $weight += self[$x2;$y2];
          take $x2;
          take $y2;
          take $weight;
        }
      }
    }
  }
  method h-neighbors(Int $x, Int $y) {
    flat
      self.neighbors-and-weights($x, $y, (<1 2 3> X 0)),
      self.neighbors-and-weights($x, $y, (<-1 -2 -3> X 0));
  }
  method v-neighbors(Int $x, Int $y) {
    flat
      self.neighbors-and-weights($x, $y, (0 X <1 2 3>)),
      self.neighbors-and-weights($x, $y, (0 X <-1 -2 -3>));
  }
  method neighbors(Int $x, Int $y) {
    gather {
      for ([-1,0],[1,0],[0,-1],[0,1]) -> [$dx, $dy] {
        my $x2 = $x + $dx;
        my $y2 = $y + $dy;
        take [$x2, $y2] if self[$x2;$y2]:exists;
      }
    }
  }
}


sub dijkstra(ListGraph $graph, $source, $dest) {
  my %dist;
  my %prev;
  my @q = [];

  for $graph.enumerate-vertices -> $v {
    %dist{$v} = Inf;
    %prev{$v} = Nil;
    push @q, $v;
  }
  %dist{$source} = 0;

  my $i = 0;
  while @q.elems {
    # say "---";
    say "Q loop #{$i++} \$#q is {@q.elems}";
    # say "dist is {@dist}";
    # say "q is {@q}";
    my $u;
    my $mindist = Inf;
    for @q {
      if %dist{$_} < $mindist {
        $mindist = %dist{$_};
        $u = $_;
      }
    }
    unless defined $u {
      die "U is undefined\n";
    }
    if $u ~~ $dest {
      say %dist{$dest};
      return %prev;
    }
    # say "U is {$u} mindist is {$mindist}";
    @q = @q.grep: { $_ ne $u }

    my @nw = $graph.neighbors($u);
    for @nw { .say }
    my @neighbors = @nw.map(*{'v'});
    my @w = @nw.map(*{'w'});
    say @neighbors;
    say @w;
    say "neigbors of {$u} == {@neighbors}";
    @neighbors = @neighbors.grep: { $_ ∈ @q };
    say "neigbors ∈ Q of {$u} == {@neighbors}";
    say "updating {@neighbors.elems} neighbors";
    for @nw -> $x {
      my $v = $x{'v'};
      my $w = $x{'w'};
      my $alt = %dist{$u} + $w;
      say "alt ({$v}) = $alt";
      if $alt < %dist{$v} {
        %dist{$v} = $alt;
        %prev{$v} = $u;
      }
    }
  }

  return Nil;
}

my @lines = lines();
my $width = @lines[0].chars;
my $height = @lines.elems;

my $m = Matrix.new(width => $width, height => $height);
for 0..$height-1 -> $y {
  $m.parse-row(@lines[$y], $y);
}

my $g = $m.to-graph;
#say $g;

# my $g = Graph.new(width => @lines[0].chars, height => @lines.elems);
# for 0..@lines.elems-1 -> $row {
#   for 0..@lines[$row].chars-1 {
#     $g.add-node-weight(x=>$^col, y=>$row, w=>substr(@lines[$row], $^col, 1));
#   }
# }
# 
# my $dst = $g.index(x => $g.width-1, y => $g.height-1);
my %prev = dijkstra($g, 'start', 'finish');
my @path = [];
my $u = 'finish';
if defined %prev{$u} {
  while defined $u {
    unshift @path, $u;
    $u = %prev{$u};
  }
}
# for 0..$g.height-1 -> $y {
#   for 0..$g.width-1 -> $x {
#     my $v = $g.index(y => $y, x => $x);
#     print "\e[31m" if ($v ∈ @path);
#     print substr(@lines[$y], $x, 1);
#     print "\e[m" if ($v ∈ @path);
#   }
#   print "\n";
# }
# for @path -> $v {
#   say $g.node-str($v);
# }
