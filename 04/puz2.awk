#!/usr/bin/mawk -f

function addmult(card, addend) {
  if (! (card in mult))
    mult[card] = 1
  mult[card] += addend
}

BEGIN {
  FS = "(: +|^Card | *\| *)"
  cardnum = 2
  Fwinning = 3
  Fyou = 4
}

{
  matches = 0
  addmult(FNR, 0) # Make sure this card's multiplier is at least 1
  split($Fwinning, Lwinning, / +/)
  split($Fyou, Lyou, / +/)
  for (i in Lyou) {
    #print "you[Lyou[", i, "]] = you[", Lyou[i], "] = 1"
    you[Lyou[i]] = 1
  }
  for (i in Lwinning) {
    #print "Lwinning[", i, "] = ", Lwinning[i], "in you?"
    if (Lwinning[i] in you) {
      matches++
    }
  }
  for (i = FNR+1; i<FNR+1+matches; i++)
    addmult(i, mult[FNR])
  # Clear arrays before next pass
  delete Lwinning
  delete Lyou
  delete you
}

END {
  cnt = 0
  for (i = 1; i <= NR; i++) {
    if (i in mult) {
      cnt += mult[i]
    } else {
      print "mult[" i "] is not present"
      exit 1
    }
  }
  print cnt, "cards total"
}
