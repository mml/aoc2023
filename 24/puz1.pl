#!/usr/bin/perl
require 5;
use strict;
use warnings;

my @rows;
my $total = 0;
my($min,$max) = @ARGV;

while (<STDIN>) {
  chomp;
  my @nums = m{(\d+), \s* (\d+), \s* (\d+) \s*
    \@ \s* (-?\d+), \s* (-?\d+), \s* (-?\d+)}x or die "$_";
  push @rows, [@nums];
}

sub solve {
  my($a, $b) = @_;
  my($px0, $py0, $pz0, $vx0, $vy0, $vz0) = @$a;
  my($px1, $py1, $pz1, $vx1, $vy1, $vz1) = @$b;

  printf "A: $px0, $py0, $pz0 @ $vx0, $vy0, $vz0\n";
  printf "B: $px1, $py1, $pz1 @ $vx1, $vy1, $vz1\n";
  my $x_divisor = ($vx1*$vy0 - $vx0*$vy1);
  if ($x_divisor == 0) {
    print "Parallel\n";
    return;
  }
  my $x = -($py0*$vx0*$vx1 - $py1*$vx0*$vx1 - $px0*$vx1*$vy0 + $px1*$vx0*$vy1)/$x_divisor;
  my $y = -(($py1*$vx1*$vy0 - $py0*$vx0*$vy1 + $px0*$vy0*$vy1 - $px1*$vy0*$vy1)/(-($vx1*$vy0) + $vx0*$vy1));
  foreach my $check (
    ($x - $px0)*$vx0,
    ($y - $py0)*$vy0,
    ($x - $px1)*$vx1,
    ($y - $py1)*$vy1
  ) {
    if ($check < 0) {
      printf "in the past\n";
      return;
    }
  }
  printf "(at x=%.3f, y=%.3f)\n", $x, $y;
  unless (($min <= $x and $x <= $max) and ($min <= $y and $y <= $max)) {
    printf "outside the test area\n";
    return;
  }
  {
    ++$total;
  }
}

for (my $i = 0; $i <= $#rows; ++$i) {
  for (my $j = $i+1; $j <= $#rows; ++$j) {
    solve($rows[$i], $rows[$j]);
  }
}

print "\n$total\n";
