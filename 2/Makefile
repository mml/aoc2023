PROG1 = puz1.jl

default: run

test: test1

run: run1

test1:
	chmod +x $(PROG1)
	./$(PROG1) < test1.txt

run1:
	chmod +x $(PROG1)
	./$(PROG1) < input.txt
