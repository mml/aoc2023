#!/usr/bin/zsh -f
# vim:mp=make:

setopt BASH_REMATCH

typeset -A left
typeset -A right

read inst
echo $inst

# zshall
while read nodeline; do
  if [[ ! "$nodeline" =~ '(...) = \((...), (...)\)' ]] {
    continue
  }
  left[$BASH_REMATCH[2]]="$BASH_REMATCH[3]"
  right[$BASH_REMATCH[2]]="$BASH_REMATCH[4]"
done

cur=AAA
i=1
n=0

while [[ "$cur" != "ZZZ" ]] {
  case "$inst[$i]" in
    L)
      cur="$left[$cur]"
      ;;
    R)
      cur="$right[$cur]"
      ;;
  esac
  (( n++ ))
  if (( ++i > $#inst )) {
    i=1
  }
}
echo $n
