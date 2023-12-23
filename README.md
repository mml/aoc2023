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
9. [Kotlin](https://kotlinlang.org/) is certainly less tedious than Java.  But
   unlike Scala, if you understand Java semantics (sadly, I do -- even though
   that experience is years old), it's pretty easy to get rolling.  I didn't
   need any of its nice lambda syntax or lazy/streaming pipeline stuff for this
   one.  It's just your basic recursive stream differentation!
10. [Lua](https://www.lua.org/) is a powerful system for its light weight, but
    I found myself making many mistakes that were discovered cryptically at
    runtime.  A lengthy debug cycle and `local` variable declarations peppered
    everywhere.  The Lua implementation is an impressive feat, but I wouldn't
    use Lua again unless it was required.
11. [Scala](https://www.scala-lang.org/) strikes me as a pretty decent choice
    if you must work in a JVM environment.  It seems a lot more to the point
    than Kotlin, but it's still very confusing if you're used to working with
    pairs, simple recursive functions, and destructuring assignment in Scheme
    or Haskell.  I found I had a hard time understand when exactly I could use
    `foo map { bar }`, `foo map { _.bar }`, `foo.map({ ??? })` and a variety of
    other similar syntaxes.  The switch from Scala 2 to Scala 3 was also
    confusing.  It made a lot of older results I found on stackoverflow fairly
    useless.
12. [OCaml](https://ocaml.org/) has a lovely type system.
13. [R](https://www.r-project.org/) worked really well for another problem
    where "transpose the data" or "treat columns like rows" was going to be
    part of the story.
14. Rust
15. C++
16. Swift
17. xxx
18. xxx
19. [Chez Scheme](https://cisco.github.io/ChezScheme/) worked well here.  I've
    implemented a lot of compilers and interpreters in this environment.
    Parsing was perhaps the clumsiest part.
20. Python
21. Elixir
22. [Mathematica](https://www.wolfram.com/mathematica/) is a lot of fun.
    Ad-hoc pattern matching, insanely deep library, on-line help, notebook
    interaction.
