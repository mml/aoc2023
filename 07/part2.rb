#!/usr/bin/env ruby

HAND_LENGTH = 5

def rank_to_hex(c)
  case c
  when '2'..'9'
    c
  when 'T'
    'A'
  when 'J'
    '1'
  when 'Q'
    'C'
  when 'K'
    'D'
  when 'A'
    'E'
  end
end

def hand_to_digits(h)
  h.chars.map{ |c| rank_to_hex(c) }
end

def sub_matches(c, h)
  cs, remain = h.partition{ |hc| hc == c }
  return cs.count, remain
end

def permute_jokers(h)
  rv = []
  jokers, others = h.partition{ |c| c == '1' }
  if jokers.empty?
    return [h]
  elsif others.empty?
    return [jokers.map { |j| 'E' }]
  end
  others.each{ |c|
    rv.push(others + jokers.map{ |j| c })
  }
  return rv
end

def matches(h)
  if h.empty?
    []
  else
    n, h = sub_matches(h[0], h[1,HAND_LENGTH])
    if n.zero?
      matches(h)
    else
      [n+1] + matches(h)
    end
  end
end

def msd(h)
  case matches(h)
  when []
    '0'
  when [2]
    '1'
  when [2,2]
    '2'
  when [3]
    '3'
  when [2,3],[3,2]
    '4'
  when [4]
    '5'
  when [5]
    '6'
  end
end

def score(pdigs, digs)
  ([msd(pdigs)] + digs).join.to_i(16)
end

def max_score(h)
  digs = hand_to_digits(h)
  digss = permute_jokers(digs)
  digss.map{ |x| score(x, digs) }.max
end

n = 0
l = ARGF.readlines.
  map(&:chomp).
  map(&:split).
  map { |h,b|
    [
      max_score(h),
      b.to_i
    ]
  }.
  sort_by(&:first).
  each_with_index.map { |(h,b),i|
    b*(i+1)
  }.
  sum
print l
