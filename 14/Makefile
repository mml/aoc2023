PROG1 = target/debug/part1
PROG2 = part2/target/release/part2

default: $(PROG2)

$(PROG1): Cargo.lock Cargo.toml src/main.rs
	cargo build

$(PROG2): part2/Cargo.lock part2/Cargo.toml part2/src/main.rs
	cargo build --release --manifest-path=part2/Cargo.toml

test1: $(PROG1)
	./$(PROG1) < test1.txt

run1: $(PROG1)
	./$(PROG1) < input.txt

test2: $(PROG2)
	./$(PROG2) < test1.txt

run2: $(PROG2)
	./$(PROG2) < input.txt
