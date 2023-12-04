PROG = reverse.sed

run:
	./$(PROG) < bar.txt | dc

test:
	test -x $(PROG)
	./$(PROG) <  bar.txt | dc | colordiff -u bar-expected.txt -
