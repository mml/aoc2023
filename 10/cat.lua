#!/usr/bin/env lua

function copy_bytes (f)
  local size = 2^13      -- good buffer size (8K)
  while true do
    local block = f:read(size)
    if not block then break end
    io.write(block)
  end
end

local n = 0
for _, a in ipairs(arg) do
  if a == "-" then
    copy_bytes(io.input())
  else
    local f = assert(io.open(a, "r"))
    copy_bytes(f)
    assert(f:close())
  end
  n = n + 1
end

if n == 0 then copy_bytes(io.input()) end
