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
   unlike Scala, if you understand Java semantics (sadly, I do—even though
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
12. [OCaml](https://ocaml.org/) has a lovely type system, but I haven't used it
    in so long, the syntax and semantics really stymied me for awhile.  I
    realized how much more familiar I am with Haskell rather than old-school ML
    languages.  But by the end, I really got it figured out.  My high-level
    takeaway is that OCaml is a lot like Scheme with a very useful type system.
    However, the surface syntax often feels like a foe.  I always seem to end
    up with excessively long lines or unruly indentation, and for whatever
    reason I see a lot of crappy function names in my OCaml code.
13. [R](https://www.r-project.org/) worked really well for another problem
    where "transpose the data" or "treat columns like rows" was going to be
    part of the story.
14. [Rust](https://www.rust-lang.org/) is complicated.  It brings many fancy
    new ideas and a type system that is unusually strict for a language which
    appears to be fairly low-level and efficient.  I see it as playing in the
    same waters as Go, but I fight with it a lot more, and it seems to have far
    more syntax and features to master.  I stayed very much on the surface
    here, and pretty much regretted my choice the whole time.  I don't think
    that's really fair to Rust, but I just found it so damn hard to get moving
    and stay moving.  The language looks on the surface like the usual
    imperative curly-brace language, but it's not.  And then again it's not
    Haskell and it's not an ML dialect.  This neither-fish-nor-fowl feeling
    really made this language a challenge for a situation where I theoretically
    only have a day.
15. [C++](https://en.wikipedia.org/wiki/C%2B%2B) was handy here, but I think
    it's only because day 15 was so easy..  The STL was not too hard to use,
    and I only had to dip my toe gently in the water.  I got to use C++11's
    type inference for the first time.  I haven't done anything in C++ since
    maybe 2005 and had no idea this existed.  It's a nice step toward
    modernizing the language.
16. This isn't really what [Swift](https://www.swift.org/) is for.  It's a bit
    like doing an AoC problem in Objective C.  But anyway, fine language that
    didn't get in my way much, but kind of a boring choice.
17. [Raku](https://raku.org/), much like Rust, was too steep a hill to climb in
    a single day.  I underestimated that, expecting my Perl 5 facility to be
    more helpful than it was.  The language has much to offer.  In some ways,
    it begins to resemble Mathematica(!) because it has such fancy features
    (like primality testing and cross products) built right in.  It promises
    neat tricks for parallelism and asynchrony, but my attempts to use them
    never gave me useful speedups.  For a guy who started with Perl 4, it's
    definitely not Perl any more.  It's not that glue language that tames your
    previously-awful shell scripts.  What is it?  And will it ever be
    predictable enough to become a go-to tool?  Probably not for me.
18. All I knew about [Dart](https://dart.dev/) was that it was the language
    behind Flutter, which is tied very tightly to Fuchsia, my last project at
    Google.  That actually put me off learning more about it.  Felt too much
    like work.  But I'd read blog posts and seen talks by Bob Nystrom that
    encouraged me to add it to the list, and I'm glad I did.  I now think of it
    as a sane cousin of JavaScript.  It could use algebraic data types and
    better destructuring/pattern-matching in function signatures, but come on.
    Those are pretty high-level complaints and the fact is it gets many many
    other things right.  Languages like this often make simple things hard.
    Stuff like printing to the console or string formatting.  But the DWIM
    string interpolation and the simple `print()` invocation really surprised
    me.  This language is easy to get off the ground in, even with tiny, toy
    AoC projects.
19. [Chez Scheme](https://cisco.github.io/ChezScheme/) worked well here.  I've
    implemented a lot of compilers and interpreters in this environment.
    Parsing was perhaps the clumsiest part.
20. [Python](https://www.python.org/) is easy and natural, and also a language
    I've used a fair bit.  Nothing not to like.  I saved it for near the end
    because I knew if I wanted to model something with objects, Python would be
    the simplest way to do it.  This problem, with lots of hidden state and my
    idea for using a message bus seemed like a natural fit, and it was.  For
    part2, the math builtins made my life super easy.
21. Elixir
22. [Mathematica](https://www.wolfram.com/mathematica/) is a lot of fun.
    Ad-hoc pattern matching, insanely deep library, on-line help, notebook
    interaction.
23. [Perl 5](https://www.perl.org/), as I mentioned in the Raku entry, is a
    language I have a lot of experience with, but that experience stopped being
    updated around 5.10 (2010).  I discovered a few newer facilities late in
    the game that really could have helped, including signatures (formal
    parameters!) and built-in class support (finally added 2023!).  Without
    the class support, doing OO in Perl is just too much overhead IMO.  I just
    relied on global variables for things like the adjacency list.  So instead
    of "a graph", there's just "the graph".
24. xxx
25. [Racket](https://racket-lang.org/) might seem like cheating.  After all,
    it's Scheme, just like Day 19's Chez Scheme, right?  And worse, Racket's
    compiler *is now* Chez Scheme.  But Racket is its own thing.  It's the
    "language-oriented" programming language, right?  And it has a huge
    [package ecosystem](https://pkgs.racket-lang.org/).  And indeed, I relied
    upon the existing graph library, but mostly so I didn't have to reimplement
    yet another graph representation, which gets tiresome.  I implemented a
    binary heap in Racket, because I couldn't remember ever doing that before,
    and it was easy.

    If I missed out on a cool feature of the language, it was
    [for/fold](https://docs.racket-lang.org/reference/for.html) and friends.

    But mostly, yes:  I cheated in order to use my favorite language twice.
