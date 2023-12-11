#!/usr/bin/env lua

-- The coordinate space is... (1,1) is our origin, top left
-- in the Y direction, Y-1 is the previous line
-- in the X direction, X-1 is the previous char
-- For each OP, list the (X,Y) delta for the two connected cells
OP = {}
OP["J"] = {-1, 0, 0,-1}
OP["-"] = {-1, 0, 1, 0}
OP["7"] = {-1, 0, 0, 1}
OP["L"] = { 0,-1, 1, 0}
OP["|"] = { 0,-1, 0, 1}
OP["F"] = { 0, 1, 1, 0}
NEIGHBORS = {
  {-1, 0},
  { 0,-1},
  { 1, 0},
  { 0, 1},
}
DIRS = {
  N = { 0,-1},
  E = { 1, 0},
  S = { 0, 1},
  W = {-1, 0},
}

function in_bounds (x, y)
  return (0 < x and x <= xmax and 0 < y and y <= ymax)
end

Distance = {max=0}
function Distance:get (x,y)
  if in_bounds(x,y) then
    return self[y][x]
  end
  error("OH NO")
end
function Distance:update (x,y,d)
  if in_bounds(x,y) then
    local val = self:get(x,y) or d
    if d > val then
      return
    end
    self[y][x] = d
  end
end
function Distance:__tostring ()
  for y = 1,ymax do
    for x = 1,xmax do
      if self[y][x] then
        io.write(string.format("% 5d ", self[y][x]))
      else
        io.write("      ")
      end
    end
    io.write("\n")
  end
end
function Distance:max ()
  local rv = 0
  for y = 1,ymax do
    for x = 1,xmax do
      if self[y][x] and self[y][x] > rv then
        rv = self[y][x]
      end
    end
  end

  return rv
end
function Distance:find_outside ()
  for y = 1,ymax do
    if self[y][1] == nil then
      return y,1
    end
  end
  error("OH NO")
end
Flood = {}

function Flood:fill (x, y)
  local dir
  if not self:inside(x, y) then
    return
  end
  self:set(x,y)
  for dir,_ in pairs(DIRS) do
    self:fill(move(dir,x,y))
  end
end
function Flood:inside (x,y)
  if not in_bounds(x,y) then
    return false
  end
  if Distance:get(x,y) then
    return false
  end
  if self[y][x] then
    return false
  end
  return true
end
function Flood:set (x,y)
  self[y][x] = "O"
end
function Flood:__tostring ()
  for y = 1,ymax do
    for x = 1,xmax do
      if self[y][x] then
        io.write(self[y][x])
      else
        local d = Distance:get(x,y)
        if d then
          io.write(at(x,y))
        else
          io.write("_")
        end
      end
    end
    io.write("\n")
  end
end

function move (dir, x, y)
  local dx, dy = table.unpack(DIRS[dir])
  return x+dx, y+dy
end

function at (x, y)
  -- print("Looking up ("..x..","..y..")")
  -- print("Line is",grid[y])
  if 0 < x and x <= xmax and 0 < y and y <= ymax then
    return grid[y]:sub(x,x)
  end
  return nil
end

function opnext (op, x0, y0, x, y)
  -- print("opnext...", op, x0, y0, x, y)
  local t = OP[op]
  if t == nil then
    return nil
  end
  local a, b, c, d = table.unpack(t)
  if a == nil then
    return nil
  end
  local dx = x0-x
  local dy = y0-y
  -- print("dx=",dx,"dy=",dy)
  -- print(table.unpack(t))
  
  if (dx == a and dy == b) then
    return x+c, y+d
  elseif (dx == c and dy == d) then
    return x+a, y+b
  else
    return nil
  end
end

Walker = {}

function Walker:new (w)
  w = w or {}
  w.distance = w.distance or 1
  setmetatable(w, self)
  self.__index = self
  return w
end

function Walker:ch ()
  return at(self.x, self.y)
end

function Walker:step ()
  if self:ch() == 'S' then return false end
  local nx, ny = opnext(self:ch(), self.px, self.py, self.x, self.y)
  if nx == nil then
    error(string.format("OH NO %s", self))
  end
  self.px = self.x
  self.py = self.y
  self.x = nx
  self.y = ny
  self.distance = self.distance + 1
  return true
end

function Walker:__tostring ()
  return string.format(
    "(%d,%d)->(%d,%d) = '%s' (Distance %d)",
    self.px, self.py, self.x, self.y, self:ch(), self.distance
  )
end

function start_neighbors (sx, sy)
  local walkers = {}
  local x0, y0
  for _, n in ipairs(NEIGHBORS) do
    local a, b, c, d = table.unpack(n)
    x0 = sx+a
    y0 = sy+b
    ch = at(x0, y0)
    -- print("at",x0,y0,ch)
    if ch == nil then
      goto continue
    end
    x1, y1 = opnext(ch, sx, sy, x0, y0)
    if x1 ~= nil then
      -- print("FOUND",ch,"at",x0,y0)
      table.insert(walkers, Walker:new{px=sx,py=sy,x=x0,y=y0})
    end
    ::continue::
  end
  return walkers
end

grid = {}
sx = nil
ymax = 0
while true do
  local line = io.read()
  if line == nil then
    break
  end
  ymax = ymax + 1
  table.insert(grid, line)
  table.insert(Distance, {})
  table.insert(Flood, {})
  if sx == nil then
    sx = string.find(line, 'S')
    if sx then sy = ymax end
  end
end
xmax = string.len(grid[ymax])
-- print("Read "..ymax.." lines")
print("S is at ("..sx..","..sy..")")
print(at(sx,sy), " is there")

--[[
--For part two, we essentially want to perform a flood fill, but as the instructions say, we can "squeeze" between pipes.
--Consider two points with a sea of pipes on either side.  In one orientation, there is a barrier
--  X||Y
--  X||Y
--But in other orientations, there is flow
--  X--Y
--  X--Y
--How to model this?  What if we expand the grid?
--    ???
--  X?|?|?Y
--    ???
--  X?|?|?Y
--    ???
--
--    ? ?
--  X?-?-?Y
--    ? ? 
--  X?-?-?Y
--    ? ?
--
--In essence, this is thinking of the flood fill as proceeding by steps of 0.5.
--In a 4-neighbors algorithm, 
--
-- A--C
-- B--D
--
-- A(1,1) has a neigbor beneath it at (1,1.5)
--    ]]

walkers = start_neighbors(sx,sy)
for _,w in ipairs(walkers) do
  -- print(w)
end

Distance:update(sx,sy,0)
for _,w in ipairs(walkers) do
  local i = 0
  Distance:update(w.x, w.y, w.distance)
  while w:step() do
    Distance:update(w.x, w.y, w.distance)
    -- print(i,w)
    i = i + 1
  end
end

px, py = Distance:find_outside()
Flood:fill(px,py)
print(Flood:__tostring())
