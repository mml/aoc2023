#!/usr/bin/env raku

class Node {
  has Int $.x;
  has Int $.y;
}

# This represents a graph of NxM elements.  The implementation uses an adjacency matrix.
class Graph {
  has Int $.width;
  has Int $.height;
  has $.count is built;
  has @!matrix is built;

  submethod BUILD(:$!width, :$!height) {
    $!count = $!width * $!height;
    @!matrix = Array.new: $!count, $!count;
  }

  method index(:$x, :$y) { $y * $!width + $x }
  method coords($v) {
    my $y = $v div $!width;
    my $x = $v mod $!width;

    return($x,$y);
  }

  method add-node-weight(:$x, :$y, :$w) {
    my $dest = self.index(:$x, :$y);
    for ([-1,0],[1,0],[0,-1],[0,1]) -> [$dx, $dy] {
      my $x2 = $x + $dx;
      next unless 0 <= $x2 and $x2 <= $!width-1;
      my $y2 = $y + $dx;
      next unless 0 <= $y2 and $y2 <= $!height-1;
      @!matrix[self.index(x => $x2, y => $y2), $dest] = $w;
    }
  }

  method neighbors($v) {
    my @rv;
    my ($x,$y) = self.coords($v);

    my $src = self.index(:$x, :$y);
    for ([-1,0],[1,0],[0,-1],[0,1]) -> [$dx, $dy] {
      my $x2 = $x + $dx;
      next unless 0 <= $x2 and $x2 <= $!width-1;
      my $y2 = $y + $dx;
      next unless 0 <= $y2 and $y2 <= $!height-1;
      push @rv, self.index(x=>$x2, y=>$y2);
    }

    return @rv;
  }

  method edge(:$src, :$dst) {
    return @!matrix[$src, $dst];
  }

  method enumerate-vertices() { 0..$!count-1 }

  ## method add-vertex($vertex) {
  ##   %!vertices{$vertex} //= [];
  ## }
  ## 
  ## method add-edge($vertex1, $vertex2) {
  ##   self.add-vertex($vertex1);
  ##   self.add-vertex($vertex2);
  ##   
  ##   push %!vertices{$vertex1}, $vertex2;
  ##   push %!vertices{$vertex2}, $vertex1;
  ## }
  ## 
  ## method neighbors($vertex) {
  ##   return %!vertices{$vertex} // [];
  ## }
  ## 
  ## method vertices() {
  ##   return %!vertices.keys;
  ## }
}

sub dijkstra(Graph $graph, $source) {
  my @dist = Array.new: $graph.count;
  my @prev = Array.new: $graph.count;
  my @q = [];

  for $graph.enumerate-vertices() {
    @dist[$_] = Inf;
    @prev[$_] = Nil;
    push @q, $_;
  }
  @dist[$source] = 0;

  my $i = 0;
  while @q.elems {
    say "Q loop #{$i++}";
    say "dist is {@dist}";
    say "---";
    my $u;
    my $mindist = Inf;
    for @q {
      if @dist[$_] < $mindist {
        $mindist = @dist[$_];
        $u = $_;
      }
    }
    @q = @q.grep: { $_ != $u }

    for $graph.neighbors($u).grep: { $_ ∈ @q } {
      my $alt = @dist[$u] + $graph.edge(src => $u, dst => $^v);
      if $alt < @dist[$^v] {
        @dist[$^v] = $alt;
        @prev[$^v] = $u;
      }
    }
  }

  return @dist;
}

my @lines = lines();
my $g = Graph.new(width => @lines[0].chars, height => @lines.elems);
for 0..@lines.elems-1 -> $row {
  for 0..@lines[$row].chars-1 {
    $g.add-node-weight(x=>$^col, y=>$row, w=>substr(@lines[$row], $^col, 1));
  }
}

my $mindist = dijkstra($g, $g.index(x => 0, y => 0));
say $mindist;
