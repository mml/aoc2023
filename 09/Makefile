PROG1 = Part1Kt.class
RUN1 = kotlin $(PROG1)

default: run1

test1: $(PROG1)
	$(RUN1) < test1.txt

run1: $(PROG1)
	$(RUN1) < input.txt

$(PROG1): part1.kt
	kotlinc $<
