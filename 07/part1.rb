#!/usr/bin/env ruby

HAND_LENGTH = 5

def rank_to_hex(c)
  case c
  when '2'..'9'
    c
  when 'T'
    'A'
  when 'J'
    'B'
  when 'Q'
    'C'
  when 'K'
    'D'
  when 'A'
    'E'
  end
end

def hand_to_digits(h)
  h.chars.map{ |c|
    rank_to_hex(c)
  }
end

def sub_matches(c, h)
  n = 0
  remain = []
  until h.empty?
    if h[0] == c
      n+=1
    else
      remain.unshift(h[0])
    end
    h=h[1,HAND_LENGTH]
  end
  return n, remain
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

begin
  n = 0
  l = ARGF.readlines.
    map(&:chomp).
    map(&:split).
    map { |h,b|
      digs = hand_to_digits(h)
      [
        ([msd(digs)]+digs).join.to_i(16),
        b.to_i
      ]
    }.
    sort_by(&:first).
    each_with_index.map { |(h,b),i|
      b*(i+1)
    }.
    sum
  print l
  ARGF.each do |line, idx|
    (hand, bet) = line.split
    bet = bet.to_i
    print "Hand #{hand} Bet #{bet}\n"
    digs = hand_to_digits(hand)
    print digs, "\n"
    print matches(digs), "\n"
    print msd(digs), "\n"
  end
rescue EOFError => e
  # That's fine
end
