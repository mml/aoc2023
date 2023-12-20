PROG1 = part1.so

default: test1

%.so: %.ss
	echo '(compile-script "./$<")' | scheme

test1: $(PROG1)
	./$(PROG1) < test1.txt

run1: $(PROG1)
	./$(PROG1) < input.txt
