type spring = Unknown | Working | Broken
type runs = int list
type row = Row of spring list * runs
type run_match = spring list option
type input_row = InputRow of string * int list

val try_match : int -> spring list -> run_match
val gen_springs : spring list -> spring list list
val count_ways : row -> int
