# aoc2023
Based on
[Matt Might's blog post](https://matt.might.net/articles/26-languages-part1/)
I'm giving the idea of using a different language each day a shot.

1. [sed](https://en.wikipedia.org/wiki/Sed) and
   [dc](https://en.wikipedia.org/wiki/Dc_%28computer_program%29).  Both of
   these languages are like mini-assembly languages for their specific domains.
   This combo has lots of power and it's not overwhelmed by the simplicity of
   this challenge.
2. [Julia](https://julialang.org/) is a little like Matlab or R mixed with
   Scheme.  The Scheme part isn't visible in the surface syntax.  I found it
   very easy to get started and to do practical stuff since things like regular
   expressions and file I/O have wonderful, terse, first-class support.  This
   was a lucky choice once I learned enough to get started because it made the
   filtering and reduction steps really elegant.  I could remove some of the
   explicit iteration and mutation from this knowing what I know now.
