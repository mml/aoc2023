#!/usr/bin/env elixir

input = 
  IO.read(:stdio, :all)
  |> String.split("\n")

height = length(input)
width = String.length(hd input)

{s, y0} = Enum.with_index(input)
          |> Enum.find(fn {s, _i} -> String.contains?(s, "S") end)
[{x0, _} | _] = Regex.run(~r/S/, s, return: :index)

q = [{x0,y0}]

garden_plot = fn {x,y} ->
  x =
    Enum.at(input, y)
    |> String.at(x)
  x != "#"
end

reachable = fn {x,y} ->
  Enum.map([{0,1},{0,-1},{1,0},{-1,0}], fn {dx,dy} -> {dx+x,dy+y} end)
  |> Enum.filter(fn {x,y} -> 0 <= x and x < width and 0 <= y and y < height end)
  |> Enum.filter(garden_plot)
end

# step = fn(visited, q) ->
#   nq = Enum.map(q, reachable)
#        |> Enum.concat()
#   visited = Enum.uniq(visited ++ nq)
#   {visited,nq}
# end

step = fn(q) ->
  nq = Enum.map(q, reachable)
       |> Enum.concat()
  Enum.uniq(nq)
end

defmodule X do
  def steps(_, q, 0) do
    q
  end
  def steps(f, q, n) do
    nq = f.(q)
    steps(f, nq,(n-1))
  end
end

nq = X.steps(step, q, 64)

IO.inspect length(nq), label: "nq"
#IO.inspect visited, label: "visited"
