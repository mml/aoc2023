PROG1 = part1

%: %.swift
	swiftc -o $@ $<

test1: $(PROG1)
	./$(PROG1) < test1.txt

run1: $(PROG1)
	./$(PROG1) < input.txt
