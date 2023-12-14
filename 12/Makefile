PROG1 = part1
PROG2 = part2
COMPILE = ocamlopt.opt

default: test2

$(PROG1) $(PROG2) :: %: %.ml
	$(COMPILE) -g -o $@ $<

test1: $(PROG1)
	./$(PROG1) < test2.txt

run1: $(PROG1)
	./$(PROG1) < input.txt

test2: $(PROG2)
	./$(PROG2) test2.txt

run2: $(PROG2)
	./$(PROG2) input.txt

top1:
	utop -init $(PROG1).ml

top2:
	utop -init $(PROG2).ml

clean:
	rm -f $(PROG1) $(PROG2) *.cm? *.o a.out

%.debug: %.ml
	ocamlc -g -o $@ $<

debug: $(PROG2).debug
	ocamldebug $<
