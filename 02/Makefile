PROG1 = puz1.jl
PROG2 = puz2.jl

default: run

test: test2

run: run2

test1:
	chmod +x $(PROG1)
	./$(PROG1) < test1.txt

run1:
	chmod +x $(PROG1)
	./$(PROG1) < input.txt

test2:
	chmod +x $(PROG2)
	./$(PROG2) < test1.txt

run2:
	chmod +x $(PROG2)
	./$(PROG2) < input.txt
