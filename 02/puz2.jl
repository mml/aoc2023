#!/usr/bin/env julia
# Could use NamedArrays or DataFrame instead.
colidx = Base.ImmutableDict("red" => 1)
colidx = Base.ImmutableDict(colidx, "green" => 2)
colidx = Base.ImmutableDict(colidx, "blue" => 3)

mutable struct Game
  n::Int
  vals::Array{Int} # Not sure how to say "an Mx3 matrix"
end

addrow!(g::Game) =
  if length(g.vals) == 0
    g.vals = [0 0 0]
  else
    g.vals = [g.vals ; [0 0 0]]
  end
adddraw!(g::Game, color, m) = g.vals[end,colidx[color]] += m

mkgame(line) = begin
  m = match(r"^Game\s+(\d+):\s+(.*)", line)
  g = Game(parse(Int, m.captures[1]), [])
  for draws in eachsplit(m.captures[2], r";\s*")
    addrow!(g)
    for draw in eachsplit(draws, r",\s*")
      nstr, color = split(draw)
      adddraw!(g, color, parse(Int, nstr))
    end
  end
  g
end

possiblep(g) = reduce(&, g.vals .<= [12 13 14])
maxes(g) = reduce(max,g.vals;dims=1)
power(mat) = reduce(*,mat)

games = map(mkgame, eachline(stdin))
tot = sum(map(power ∘ maxes, games))
println(tot)
