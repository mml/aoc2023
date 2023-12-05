PROG1 = part1

%: %.go
	go build $<

default: run1

test1: $(PROG1)
	./$(PROG1) < test.txt

run1: $(PROG1)
	./$(PROG1) < input.txt
