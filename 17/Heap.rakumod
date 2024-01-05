use v6.d;

# This will be a binary min-heap as needed for this problem.
class Heap {
  has $size;
  has $end = 1;
  has @v is built;
  has %index = ();

  submethod BUILD(:$size) {
    say "setting size to $size";
    @v = [False xx $size+1];
  }

  method elems { $end - 1 }
  method empty { $end == 1 }
  method !parent(Int $i) { $i div 2 }
  method !child0(Int $i) { $i*2 }
  method !child1(Int $i) { $i*2 + 1 }
  method !swap(Int $i, Int $j) {
    my $tmp = @v[$i];
    @v[$i] = @v[$j];
    @v[$j] = $tmp;
    %index{@v[$i].value} = $i;
    %index{@v[$j].value} = $j;
  }
  method !less(Int $i, Int $j) {
    self!valid-index($i)
      and
    self!valid-index($j)
      and
    Less =:= @v[$i] cmp @v[$j];
  }
  method !greater(Int $i, Int $j) {
    self!valid-index($i)
      and
    self!valid-index($j)
      and
    More =:= @v[$i] cmp @v[$j];
  }
  method !valid-index(Int $i) {
    0 < $i and $i < $end;
  }
  method !correct-order(Int $i) {
    not self!greater($i, self!child0($i))
      and
    not self!greater($i, self!child1($i));
  }
  method !min-child(Int $i) {
    my $j0 = self!child0($i);
    my $j1 = self!child1($i);
    #say "min-child($i) $j0 <> $j1";
    if self!valid-index($j0) and self!valid-index($j1) {
      #say "both valid";
      return self!less($j0, $j1) ?? $j0 !! $j1;
    }
    if self!valid-index($j0) {
      #say "j0 $j0";
      return $j0;
    }
    #say "j1 $j1";
    return $j1;
  }

  method insert($e, Int $k) {
    my $i = $end++;
    #say "\@v[$i] = $k => $e";
    @v[$i] = $k => $e;
    %index{$e} = $i;
    #say "\@v[$i] = $k => $e";
    self!swim-up($i);
  }

  method extract {
    my $root = @v[1];
    my $last = $end - 1;
    my $e = @v[$last];
    @v[1] = $e;
    %index{$e.value} = 1;
    %index{$root.value}:delete;
    @v[$last] = False;
    $end = $last;
    self!sink-down(1);
    $root.value;
  }

  method contains($e) { %index{$e}:exists }
  method decrease-key($e, Int $dk) {
    my $i = %index{$e};
    my $pair = @v[$i];
    @v[$i] = $pair.key - $dk => $e;
    self!swim-up($i)
  }

  method !swim-up(Int $i) {
    #say "swim-up $i";
    my $parent = self!parent($i);
    if self!less($i, $parent) {
      self!swap($i, $parent);
      self!swim-up($parent);
    }
  }

  method !sink-down(Int $i) {
    #say "sink-down $i";
    unless self!correct-order($i) {
      my $j = self!min-child($i);
      self!swap($i, $j);
      #say "sink-down $i -> $j";
      self!sink-down($j);
    }
  }
}
