PROG1 = part1
PROG2 = part2

%: %.go
	go build $<

default: run2

test1: $(PROG1)
	./$(PROG1) < test.txt

run1: $(PROG1)
	./$(PROG1) < input.txt

run2: $(PROG2)
	./$(PROG2) < input.txt
