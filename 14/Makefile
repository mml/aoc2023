PROG1 = target/debug/part1

default: test1

$(PROG1): Cargo.lock Cargo.toml src/main.rs
	cargo build

test1: $(PROG1)
	./$(PROG1) < test1.txt

run1: $(PROG1)
	./$(PROG1) < input.txt
