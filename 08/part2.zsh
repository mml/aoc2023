#!/usr/bin/zsh -f

# zshoptions
setopt BASH_REMATCH
setopt SHORT_LOOPS

# zshmodules
zmodload zsh/mathfunc

typeset -A left
typeset -A right
typeset -a curs
typeset -a ns

read inst
echo $inst

curs=()
# zshall
while read nodeline; do
  if [[ ! "$nodeline" =~ '(...) = \((...), (...)\)' ]] {
    continue
  }
  node="$BASH_REMATCH[2]"
  left[$node]="$BASH_REMATCH[3]"
  right[$node]="$BASH_REMATCH[4]"
  if [[ "$node" =~ 'A$' ]] {
    curs+=($node)
  }
done

check_there() {
  cur="$curs[$j]"
  if [[ "$cur[3]" != 'Z' ]] {
    return
  }
  there=1
}

for (( j = 1; j <= $#curs; j++ )); do
  i=1
  n=0
  there=0
  echo "J=$j"

  while true; do
    check_there
    if (( there )) {
      break
    }
    case "$inst[$i]" in
      L)
        curs[$j]="$left[$curs[$j]]"
        ;;
      R)
        curs[$j]="$right[$curs[$j]]"
        ;;
    esac
    (( n++ ))
    if (( ++i > $#inst )) {
      i=1
    }
  done
  echo $n
  ns[$j]=$n
done

# Iteratively build lcm(ns[1],...,ns[j])
# Starting with lcm(ns[1]) which is just ns[1]
(( lcm = ns[1] ))
echo "lcm[1]=$lcm"
for (( j = 2; j <= $#ns; j++ )) {
  (( a = lcm ))
  (( b = ns[j] ))
  if (( a < b )) {
    (( larger = b ))
    (( b = a ))
    (( a = larger ))
  }
  while true; do
    (( rem = a % b ))
    if (( rem == 0 )) {
      (( gcd = b ))
      echo "gcd($lcm,$ns[$j]) = $gcd"
      break
    }
    (( a = b ))
    (( b = rem ))
  done
  (( lcm = ns[j]*(lcm/gcd) ))
  echo "lcm[$j]=$lcm"
}
echo $lcm
