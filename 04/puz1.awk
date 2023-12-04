#!/usr/bin/mawk -f

BEGIN {
  FS = "(: +|^Card | *\| *)"
  cardnum = 2
  Fwinning = 3
  Fyou = 4
  tot = 0
}

{
  points = 0
  split($Fwinning, Lwinning, / +/)
  split($Fyou, Lyou, / +/)
  for (i in Lyou) {
    #print "you[Lyou[", i, "]] = you[", Lyou[i], "] = 1"
    you[Lyou[i]] = 1
  }
  for (i in Lwinning) {
    #print "Lwinning[", i, "] = ", Lwinning[i], "in you?"
    if (Lwinning[i] in you) {
      #print "Yes"
      if (points == 0)
        points = 1
      else
        points *= 2
    }
  }
  tot += points
  # Clear arrays before next pass
  delete Lwinning
  delete Lyou
  delete you
}

END {
  print tot, "points"
}
