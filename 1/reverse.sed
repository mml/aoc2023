#!/usr/bin/sed -Ef

# Create a dc macro to add our two digits to a running total
1i\
[r 10* ++]sa 0

h # Save a copy
:reverse
/../! bonechar

# Line reversing code from GNU sed manual  https://is.gd/KVds88
# Reverse a line.  Begin embedding the line between two newlines
s/^.*$/\n&\n/

# Move first character at the end.  The regexp matches until
# there are zero or one characters between the markers
tx
:x
s/(\n.)(.*)(.\n)/\3\2\1/
tx

# Remove the newline markers
s/\n//g

:onechar
/</ bforward

# find last character in reversed line
s/([0-9]|enin|thgie|neves|xis|evif|ruof|eerht|owt|eno)/>\1</1
treverse

:forward
x
s/([0-9]|one|two|three|four|five|six|seven|eight|nine)/<\1>/1
s/^.*<(.*)>.*$/\1/g
G
s/\n.*<(.*)>.*$/ \1/g

s/one/1/g
s/two/2/g
s/three/3/g
s/four/4/g
s/five/5/g
s/six/6/g
s/seven/7/g
s/eight/8/g
s/nine/9/g

s/$/ lax/

$a\
p
