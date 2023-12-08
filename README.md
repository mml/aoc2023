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
3. I chose *C* because it seemed to fit the nature and simplicity of the
   problem.  I wanted a linear solution here, and I thought if I mmap'd the
   file I could just treat it like a 2D array and create a spatial mask around
   symbols.  I knew there was a risk that part 2 would throw me a curveball
   that would make this solution brittle, but it wasn't too bad in the end.
   But I'm glad I don't have to maintain this code!
4. `Awk` worked out pretty well.  This is almost exactly how I would have done
   it in Perl, just without tweaking FS.  Instead I'd have used regex capture
   groups from the start.  Hard to believe, but I think this would have been
   more readable in Perl.
5. I have a lot of experience with [Go](https://go.dev/).  The type system was
   a good fit for the problem today.  And the OO features helped, too.  As is
   typical for Go programs, error checking can be cumbersome and verbose.  The
   same could be said for the parsing part of the program.  I like that Go is
   very relaxed about where you can write a method (anywhere) and how trivial
   it is to change a "normal" function into a method.  It makes it easy to
   quickly create and modify solutions for these small problems.  Also, I
   wanted to do this without relying on 64-bit integers or bignums, and the Go
   compiler's pretty strict about type mixing here, which forced me to be
   explicit about type conversions.  (My solution could still overflow.)
6. [JavaScript](https://developer.mozilla.org/en-US/docs/Web/javascript) worked
   just fine for this very simple problem.  This one was easy as long as your
   integer type didn't overflow.  The "integer" (Number) type in JS is actually
   float64, which can represent integer values accurately up to 2^53-1.  This
   problem would have overflowed uint32 but fit fine here.
7. [Ruby](https://www.ruby-lang.org/) is really great for problems like this.
   I sketched the solution on paper the night before, in Scheme, and it shows
   in the way I "take the cdr" of arrays over and over again.  Very
   inefficient, lots of copying, but it seems to work fine.
8. Using [zsh](https://www.zsh.org/) is really more of a novelty act.
   Something you do on a dare.  I didn't use any external programs, so this
   isn't just a "pipeline" solution, but it uses zsh as a language in its own
   right.  This problem was a good fit because it didn't need fancy types or
   very many functions.  It's the sort of thing that works just fine with a few
   global variables and would also be easy in BASIC.  Even the Euclidean
   algorithm stuff.
