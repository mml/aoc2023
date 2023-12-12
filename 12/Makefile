PROG1 = part1
PROG2 = part2
COMPILE = ocamlc

default: test1

%.cmi: %.mli
	ocamlc $<

part1 part2 :: %: %.ml %.cmi
	$(COMPILE) -g -o $@ $<

test1: $(PROG1)
	./$(PROG1) < test2.txt

run1: $(PROG1)
	./$(PROG1) < input.txt

top1:
	utop $(PROG1).ml

clean:
	rm -f $(PROG1) $(PROG2) *.cm? *.o a.out

debug: $(PROG1)
	ocamldebug $(PROG1)
