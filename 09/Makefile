PROG1 = Part1Kt.class
PROG2 = Part2Kt.class
RUN1 = kotlin $(PROG1)
RUN2 = kotlin $(PROG2)

default: test2

test1: $(PROG1)
	$(RUN1) < test1.txt

run1: $(PROG1)
	$(RUN1) < input.txt

test2: $(PROG2)
	$(RUN2) < test1.txt

run2: $(PROG2)
	$(RUN2) < input.txt

Part%Kt.class: part%.kt
	kotlinc $<
