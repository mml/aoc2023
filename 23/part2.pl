#!/usr/bin/perl

require 5;
use warnings;
use strict;
use constant T => 1;
use constant F => 0;
use constant Inf => 1e12; # :-)
use constant VERTEX => 0;
use constant WEIGHT => 1;

use Carp 'confess'; # die with backtrace
use Data::Dumper;

$| = 1;

my @rows;
my @node; # Indexed the same as @rows
my $start;
my $end;
my $left_node;
my @above_nodes;

# These are adjacency lists.
our %neighbors;

sub char($$) {
  my($row, $col) = @_;

  if ($row < 0 or $row > $#rows) {
    return '';
  }

  my $chars = $rows[$row];

  if ($col < 0 or $col >= length $chars) {
    return '';
  }
  return substr $chars, $col, 1;
}

sub red($) {
  print "\e[31m@_\e[m";
}

sub node_name($$$) {
  my($row, $col, $type) = @_;
  return "[row=$row,col=$col,$type]";
}

sub node_type($) {
  my($name) = @_;
  $name =~ /,([Ov>])\]$/ or die;
  return $1;
}

sub node_row($) {
  $_[0] =~ /row=(\d+)/ or confess "$_[0]";
  return $1;
}

sub node_col($) {
  $_[0] =~ /col=(\d+)/ or die;
  return $1;
}

sub outdegree($) { $#{$neighbors{$_[0]}}+1 }

sub dist($$) {
  my($a, $b) = @_;

  return abs(node_row($a) - node_row($b)) + abs(node_col($a) - node_col($b));
}

sub add_neighbor($$;$) {
  my($src,$dst,$weight) = @_;
  $weight = dist $src, $dst unless defined $weight;

  push @{$neighbors{$src}}, [$dst, $weight];
}

sub edge_vertex($) { $_[0]->[VERTEX] }
sub edge_weight($) { ref $_[0] or confess "$_[0]"; $_[0]->[WEIGHT] }
sub neighbors($) {
  map { $_->[VERTEX] } @{$neighbors{$_[0]}};
}

sub weight($$) {
  my($src, $dst) = @_;

  my $edges = $neighbors{$src};
  foreach my $edge (@$edges) {
    next unless edge_vertex $edge eq $dst;
    return edge_weight $edge;
  }

  confess "$src and $dst aren't connected";
}


sub connect_horiz($$) {
  my($l, $r) = @_;

  if (node_type $l ne 'v') {
    add_neighbor $l, $r;
  }
  if (node_type $r eq 'O' and node_type $l eq 'O') {
    add_neighbor $r, $l;
  }
}

sub connect_vert($$) {
  my($u, $d) = @_;

  if (node_type $u ne '>') {
    add_neighbor $u, $d;
  }
  if (node_type $d eq 'O' and node_type $u eq 'O') {
    add_neighbor $d, $u;
  }
}

sub repoint_edge($$$$) {
  my($src, $dst_old, $dst_new, $dweight) = @_;

  my $edges = $neighbors{$src};
  foreach my $edge (@$edges) {
    my $w = edge_vertex $edge;
    unless (defined $w) {
      warn Dumper($edge);
      confess "undefined $w in edge";
    }
    next unless $w eq $dst_old;
    #warn "($src -> $dst_old) => $dst_new ($edge->[WEIGHT] -> @{[$edge->[WEIGHT] + $dweight]})\n";
    $edge->[VERTEX] = $dst_new;
    $edge->[WEIGHT] += $dweight;
  }
}

sub remove_edge($$) {
  my($src, $dst) = @_;

  my $edges = $neighbors{$src};
  for (my $i = 0; $i <= $#$edges; ++$i) {
    if (edge_vertex $edges->[$i] eq $dst) {
      splice @$edges, $i, 1;
      my @ns = neighbors $src;
      #warn "Edges $src == @ns\n";
      return;
    }
  }
}

sub assert_gone($) {
  my $u = shift;

  confess "$u exists" if exists $neighbors{$u};
  foreach my $v (keys %neighbors) {
    foreach my $w (neighbors $v) {
      confess "$u <-- $v" if $w eq $u;
    }
  }
}

sub assert_undirected() {
  my $ok = T;

  my @us = keys %neighbors;

  foreach my $u (@us) {
    foreach my $v (neighbors $u) {
      if (weight($u, $v) != weight($v, $u)) {
        warn "$u<->$v weight mismatch\n";
        $ok = F;
      }
    }
  }

  for (my $i = 0; $i <= $#us; ++$i) {
    my $u = $us[$i];
    for (my $j = $i+1; $j <= $#us; ++$j) {
      my $v = $us[$j];
      foreach my $u_edge ($neighbors{$u}) {
        my($w, $weight) = @$u_edge;
        if ($w eq $v) {
          if (weight($v, $w) != $u_edge->[WEIGHT]) {
            warn "$v<->$w weight mismatch\n";
            $ok = F;
          }
        }
      }
    }
  }

  confess "Not undirected" unless $ok;
}

sub add_node($$$) {
  my($row, $col, $type) = @_;
  my $name = node_name $row, $col, $type;
  $neighbors{$name} = [];
  while ($#node < $row) {
    push @node, [];
  }
  $node[$row][$col] = $name;
  if (defined $left_node) {
    connect_horiz $left_node, $name;
  }
  if (defined $above_nodes[$col]) {
    connect_vert $above_nodes[$col], $name;
  }
  $left_node = $name;
  $above_nodes[$col] = $name;
  return $name;
}

sub dfs(&%) {
  my($visit, %arg) = @_;
  my %visited;

  my $dfs;
  $dfs = sub {
    my $v = shift;
    return if exists $visited{$v};
    {
      local $_ = $v;
      if (exists $arg{should_visit}) {
        return unless $arg{should_visit}->($v);
      }
      &$visit($v);
    }
    $visited{$v} = T;
    foreach my $w (neighbors $v) {
      #print "consider $w\n";
      $dfs->($w);
    }
    if (exists $arg{epilogue}) {
      local $_ = $v;
      $arg{epilogue}->($v);
    }
  };

  if (exists $arg{v0}) {
    $dfs->($arg{v0});
  } else {
    foreach my $v (keys %neighbors) {
      $dfs->($v);
    }
  }
}

sub topo(&) {
  my($visit) = @_;
  my %reverse;

  # build reverse adjacency lists
  foreach my $src (keys %neighbors) {
    foreach my $dst (neighbors $src) {
      push @{$reverse{$dst}}, $src;
      #print "$dst <-- $src\n";
    }
  }

  my @vs;
  my %visited;

  my $topo;
  $topo = sub {
    my $v = shift;
    $visited{$v} = T;
    my $ws = $reverse{$v};
    foreach my $w (@$ws) {
      $topo->($w) unless exists $visited{$w};
    }
    push @vs, $v;
  };

  foreach my $v (keys %neighbors) {
    $topo->($v) unless exists $visited{$v};
  }

  foreach (@vs) {
    &$visit($_);
  }
}

sub row_wise(&) {
  my($visit) = @_;

  foreach my $node_list (@node) {
    foreach my $node (@$node_list) {
      next unless defined $node and length $node;
      next unless exists $neighbors{$node};
      {
        local $_ = $node;
        $visit->($node);
      }
    }
  }
}

sub has_cycle() {
  my %visited;
  my %finished;

  my $dfs;
  $dfs = sub {
    my $v = shift;
    confess "undef \$v" unless defined $v;
    return F if exists $finished{$v};
    confess "Cycle detected" if exists $visited{$v};
    $visited{$v} = 1;
    #warn "\@{\$neighbors{'$v'}} --> @{$neighbors{$v}}\n";
    foreach my $w (neighbors $v) {
      return T if $dfs->($w);
    }
    $finished{$v} = 1;
    return F;
  };
  foreach my $v (keys %neighbors) {
    if ($dfs->($v)) {
      confess "Cycle detected.\n";
      return T;
    }
  }

  warn "No cycle detected.\n";
  return F;
}

sub longest_path {
  no warnings 'recursion';
  my $maxlen = 0;
  my %visited;
  #my @path;

  my $search;
  $search = sub {
    my($u, $len) = @_;

    $visited{$u} = T;
    #push @path, $u;
    #printf "%s ..(%d).. %s\n", $path[0], $#path+1, $u;

    if ($u eq $end) {
      if ($len > $maxlen) {
        print "new maxlen = $len\n";
        $maxlen = $len;
      }
    } else {
      foreach my $v (neighbors $u) {
        unless ($visited{$v}) {
          my $weight = weight $v, $u;
          $search->($v, $len+$weight);
        }
      }
    }
    #pop @path;
    $visited{$u} = F;
  };

  $search->($start, 0);
  return $maxlen;
}

# This simplifies the graph by contracting any edge between pairs of nodes both
# with outdegree of 2.
sub collapse() {
  my @q = grep { outdegree $_ eq 2 } keys %neighbors;
  my $removed_count = 0;

  foreach my $v (@q) {
    #next unless node_type $v eq 'O';
    next unless exists $neighbors{$v};
    my $target_edges = $neighbors{$v};
    foreach my $target_edge (@$target_edges) {
      my $target = edge_vertex $target_edge;
      next if $target eq $start or $target eq $end;
      #next unless node_type $target eq 'O';
      next unless grep /\Q$target\E/, @q;

      # We can safely collapse $target into $v;
      ++$removed_count;
      my $target_weight = edge_weight $target_edge;
      my $edges = $neighbors{$target};
      delete $neighbors{$target};
      undef $node[node_row $target][node_col $target];
      foreach my $edge (@$edges) {
        my $w = edge_vertex $edge;
        next if $w eq $v;
        next if grep { $_->[VERTEX] =~ /\Q$w\E/ } @$target_edges; # skip existing neighbors
        my $new_weight = edge_weight($edge) + $target_weight;
        #warn "$v => $w ", edge_weight $edge, " -> ", $new_weight, "\n";
        add_neighbor $v, $w, $new_weight;
      }

      remove_edge $v, $target;
      foreach my $u (keys %neighbors) {
        repoint_edge $u, $target, $v, $target_weight;
      }

      assert_gone $target;
    }
  }

  return $removed_count;
}

sub fix_collapse() {
  my $removed_count;

  print "Collapsing";
  do {
    print ".";
    #print "\n"; draw();
    $removed_count = collapse;
  } while $removed_count;

  print "\n";
}

sub draw() {
  for (my $row = 0; $row <= $#rows; ++$row) {
    my @row_nodes;
    for (my $col = 0; $col < length $rows[$row]; ++$col) {
      my $node = $node[$row][$col];
      if (defined $node) {
        red node_type $node;
        push @row_nodes, $node;
      } else {
        print char $row, $col;
      }
    }
    foreach my $node (@row_nodes) {
      print " [";
      foreach my $w (neighbors $node) {
        print " (", node_row $w, ",", node_col $w, ")=", weight $node, $w;
      }
      print " ]";
    }
    print "\n";
  }
}

while (<STDIN>) {
  chomp;
  #s/[>v]/./g;
  push @rows, $_;
}
close STDIN;

for (my $row = 0; $row <= $#rows; ++$row) {
  undef $left_node; # This is the last node *in this row*
  local $_ = $rows[$row];
  die unless /^#.*#$/; # Algorithm assumes RHS and LHS are solid borders
  for (my $col = 0; $col < length; ++$col) {
    my $lhs = char $row, $col-1;
    my $char = char $row, $col;
    my $rhs = char $row, $col+1;
    my $above = char $row-1, $col;
    my $below = char $row+1, $col;

    if ($char eq '#') {
      undef $left_node;
      undef $above_nodes[$col];
      print $char;
    } elsif ($row == 0) {
      red 'S';
      $start = add_node $row, $col, 'O';
    } elsif ($row == $#rows) {
      red 'E';
      $end = add_node $row, $col, 'O';
    } elsif ($char eq '>' or $char eq 'v') {
      red 'O';
      add_node $row, $col, 'O';
    } elsif (($lhs ne '.' or $rhs ne '.') and ($below ne '.' or $above ne '.')) {
      red 'O';
      add_node $row, $col, 'O';
    } else {
      print $char;
    }
  };
  print "\n";
}
assert_undirected;
fix_collapse;
assert_undirected;
#print "--\n";
#collapse;
print "==\n";
#has_cycle;

sub print {
  print "start=" if $_ eq $start;
  print "end=" if $_ eq $end;
  print "$_:";
  for my $w (neighbors $_) {
    print " $w";
  }
  print "\n";
};

print "\n";
draw;
print scalar keys %neighbors, " vertices\n";
print "Longest path is ", longest_path, "\n";

# row_wise(\&print);
# print "--8<---8<---8<--\n";
# dfs(\&print, v0 => $start);
print "--8<---8<---8<--\n";
#topo(\&print);
#draw;
#print longest, "\n";
