#!/usr/bin/env python

import functools
import operator
import collections
import sys
import re
import math

L = 'L'
H = 'H'
OFF = 'OFF'
ON = 'ON'
total = collections.defaultdict(lambda: 0)

class Pulse:
    def __init__(self, level, src):
        self.level = level
        self.src = src

class Module:
    def __init__(self, name, bus):
        self.subs = set()
        self.name = name
        self.bus = bus
        self.sent = []

    def record_sent(self, level):
        while len(self.sent) <= presses:
            self.sent.append([])
        self.sent[presses].append(level)

    def add_input(self, name):
        self.subs.add(name)

    def maybe_recv(self, source, pulse):
        if source in self.subs:
            total[pulse.level] += 1
            self._recv(source, pulse)

    def pulse(self, level):
        self.record_sent(level)
        self.bus.publish(Pulse(level, self.name))

class Sink(Module):
    def _recv(self, source, pulse):
        pass

class Broadcast(Module):
    def _recv(self, source, pulse):
        self.pulse(pulse.level)

class F(Module):
    def __init__(self, name, bus):
        self.state = OFF
        Module.__init__(self, name, bus)

    def _recv(self, source, pulse):
        if pulse.level == L:
            if self.state == OFF:
                self.state = ON
                self.pulse(H)
            else:
                self.state = OFF
                self.pulse(L)

class Con(Module):
    def __init__(self, name, bus):
        self.mem = {}
        Module.__init__(self, name, bus)

    def add_input(self, name):
        Module.add_input(self, name)
        self.mem[name] = L

    def _recv(self, source, pulse):
        self.mem[source] = pulse.level
        if functools.reduce(operator.and_, [x == H for x in self.mem.values()]):
            self.pulse(L)
        else:
            self.pulse(H)

class Bus:
    def __init__(self):
        self.q = collections.deque()

    def publish(self, msg):
        self.q.append(msg)

    def empty(self):
        return len(self.q) == 0

    def take(self):
        return self.q.popleft()

bus = Bus()
def make_sink():
    return Sink('foo', bus)

module = collections.defaultdict(make_sink)
def parse_module(src, bus):
    if src == 'broadcaster':
        module[src] = Broadcast(src, bus)
    else:
        m = re.match(r'^%(.*)', src)
        if m:
            module[m.group(1)] = F(m.group(1), bus)
        else:
            m = re.match(r'^&(.*)', src)
            if m:
                module[m.group(1)] = Con(m.group(1), bus)

lines = sys.stdin.readlines()
for x in map(str.rstrip, lines):
    (src,dsts) = re.split(r'\s*->\s*', x)
    parse_module(src, bus)
for x in map(str.rstrip, lines):
    (src,dsts) = re.split(r'\s*->\s*', x)
    m = re.search(r'[a-z]+', src)
    for dst in re.split(r',\s*', dsts):
        module[dst].add_input(m.group())
module['broadcaster'].add_input('button')
presses = 0
for i in range(15_000):
    bus.publish(Pulse(L, 'button'))
    presses = presses + 1
    while not bus.empty():
        msg = bus.take()
        for mod in module.values():
            mod.maybe_recv(msg.src, msg)
print(total[H])
print(total[L])
print(total[H]*total[L])
print("---")

def pulse_list_to_str(l):
    if len(l) == 0:
        return "∅"
    it = ''.join(['●' if x == 'H' else '◌' for x in l])
    return f'⟨{it}⟩'

def dump_history(k):
    mod = module[k]
    sent = mod.sent
    sys.stdout.write(f"{k}:")
    sent0 = None
    n = 0
    for i in range(1, len(sent)+1):
        if i < len(sent) and sent[i] == sent0:
            n = n + 1
            continue
        else:
            if n > 1:
                sys.stdout.write(f"×{n}")
            if i >= len(sent):
                break
            sent0 = sent[i]
            n = 1
        sys.stdout.write(pulse_list_to_str(sent[i]))
    sys.stdout.write("\n")

def find_his(k):
    mod = module[k]
    sent = mod.sent
    sys.stdout.write(f"{k}:")
    for i in range(len(sent)):
        senti = sent[i]
        if H in senti:
            sys.stdout.write(f" [{i}]={pulse_list_to_str(senti)}")
    sys.stdout.write("\n")

def bfs(k, visit):
    dumped = set()
    q = [k]
    while q:
        k = q.pop(0)
        for inp in module[k].subs:
            if inp not in dumped and inp not in q:
                q.append(inp)
        visit(k)
        dumped.add(k)

#bfs('rx', dump_history)
#bfs('rx', find_his)

def first_hi(k):
    mod = module[k]
    sent = mod.sent
    for i in range(len(sent)):
        if H in sent[i]:
            return i
    return math.inf

factors = [first_hi(k) for k in module['hp'].subs]
x = math.lcm(*factors)
print(f"lcm({factors}) = {x}")
