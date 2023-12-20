PROG1 = part1.so
PROG2 = part2.so

default: test2

%.so: %.ss
	echo '(compile-script "./$<")' | scheme

test1: $(PROG1)
	./$(PROG1) < test1.txt

run1: $(PROG1)
	./$(PROG1) < input.txt

test2: $(PROG2)
	./$(PROG2) < test1.txt

run2: $(PROG2)
	./$(PROG2) < input.txt
