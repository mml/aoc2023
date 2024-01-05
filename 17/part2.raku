#!/usr/bin/env -S raku -I .

use v6.d;

use Heap;

class Node {
  has Int $.x;
  has Int $.y;
}

# This class uses adjacency lists.  It appears to be a good choice since the
# graph ends up fairly sparse.
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

  method gist {
    join '', gather {
      for %!edges.kv -> $src, $dsts {
        when $dsts.elems > 0 {
          take "$src:";
          for $dsts.values -> $x {
            take " {$x{'v'}}={$x{'w'}}";
          }
          take "\n";
        }
      }
    }
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
    say "Created graph";
    self.add-edges($g);
    say "Added edges";
    return $g;
  }

  method vertex-name(Int $x, Int $y, Str $dir) {
    return "[$x,$y]-$dir";
  }

  method project-vertex(Str $name) {
    gather {
      for $name.match(rx/(\d+)\,(\d+)/) -> $n {
        take $n;
      }
    }
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
    $g.add-edge(self.vertex-name($.width-1, $.height-1, "V"), "finish", 0);
    $g.add-edge(self.vertex-name($.width-1, $.height-1, "H"), "finish", 0);

    return $g;
  }

  method add-edges($g) {
    for self.iter_coords -> [$x, $y] {
      print "x=$x y=$y               \r";
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
    print "\n";
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
    lazy gather {
      for 0..$!width-1 -> $x {
        for 0..$!height-1 -> $y {
          take [$x, $y];
        }
      }
    }
  }
  method neighbors-and-weights(Int $x, Int $y, @pd, @d) {
    gather {
      my $weight = 0;
      for @pd -> [$dx, $dy] {
        my $x2 = $x + $dx;
        my $y2 = $y + $dy;
        if self.exists($x2,$y2) {
          $weight += self[$x2;$y2];
        }
      }
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
      self.neighbors-and-weights($x, $y, (<1 2 3> X 0), (<4 5 6 7 8 9 10> X 0)),
      self.neighbors-and-weights($x, $y, (<-1 -2 -3> X 0), (<-4 -5 -6 -7 -8 -9 -10> X 0));
  }
  method v-neighbors(Int $x, Int $y) {
    flat
      self.neighbors-and-weights($x, $y, (0 X <1 2 3>), (0 X <4 5 6 7 8 9 10>)),
      self.neighbors-and-weights($x, $y, (0 X <-1 -2 -3>), (0 X <-4 -5 -6 -7 -8 -9 -10>));
  }
}

sub dijkstra(ListGraph $graph, $source, $dest) {
  my %dist;
  my %prev;
  my @v = $graph.enumerate-vertices;
  my $q = Heap.new(size => @v.elems);

  for @v -> $v {
    %prev{$v} = Nil;
    if $v eq $source {
      %dist{$v} = 0;
      $q.insert($v, %dist{$v});
    } else {
      %dist{$v} = Inf;
    }
  }

  my $i = 0;
  until $q.empty {
    say "Q loop №{$i++} \$#q is {$q.elems}";
    my $u = $q.extract;
    unless defined $u {
      die "U is undefined\n";
    }

    my @nw = $graph.neighbors($u);
    my @neighbors = @nw.map(*{'v'});
    my @w = @nw.map(*{'w'});
    for @nw -> $x {
      my $v = $x{'v'};
      my $w = $x{'w'};
      my $alt = %dist{$u} + $w;
      if $alt < %dist{$v} {
        #say "\%dist\{$v\} = $alt";
        #say "\%prev\{$v\} = $u";
        %dist{$v} = $alt;
        %prev{$v} = $u;
        if $q.contains($v) {
          $q.decrease-key($v, $alt);
        } else {
          $q.insert($v, $alt);
        }
      }
    }
  }

  say "\%dist\{$dest\} = %dist{$dest}";
  return %prev;
}

my @lines = lines();
my $width = @lines[0].chars;
my $height = @lines.elems;

my $m = Matrix.new(width => $width, height => $height);
for 0..$height-1 -> $y {
  $m.parse-row(@lines[$y], $y);
}
say "Finished reading input";

my $g = $m.to-graph;
say $g;

my %prev = dijkstra($g, 'start', 'finish');
my @path = [];
my $u = 'finish';
if defined %prev{$u} {
  my $next;
  while defined $u {
    #say @path;
    if defined $next and $next ne 'finish' and $u ne 'start' {
      #say "[[ $u -> $next ]]";
      my ($ux, $uy) = $m.project-vertex($u);
      my ($nx, $ny) = $m.project-vertex($next);
      when $ux == $nx {
        my $ydir = ($ny-$uy)/abs($ny-$uy);
        loop (my $y = $uy+$ydir; $y != $ny; $y += $ydir) {
          unshift @path, "[$ux,$y]-H";
          #say "   [[ ($ux, $y) ]]";
        }
      }
      when $uy == $ny {
        my $xdir = ($nx-$ux)/abs($nx-$ux);
        loop (my $x = $ux+$xdir; $x != $nx; $x += $xdir) {
          unshift @path, "[$x,$uy]-V";
          #say "   [[ ($x, $uy) ]]";
        }
      }
    }
    unshift @path, $u;
    $next = $u;
    $u = %prev{$u};
  }
}
for 0..$m.height-1 -> $y {
  for 0..$m.width-1 -> $x {
    my $hl = ($m.vertex-name($x, $y, 'H') | $m.vertex-name($x, $y, 'V')) ∈ @path;
    print "\e[31m" if $hl;
    print $m[$x;$y];
    print "\e[m" if $hl;
  }
  print "\n";
}
# for @path -> $v {
#   say $v;
# }
