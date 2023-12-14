open StdLabels
open In_channel

type spring = Unknown | Working | Broken
type runs = int list
type row = Row of spring list * runs
type run_match = spring list option
type input_row = InputRow of string * int list

let inputs = [ InputRow ("???.###", [1;1;3])
             ; InputRow (".??..??...?##.", [1;1;3])
             ; InputRow ("?#?#?#?#?#?#?#?", [1;3;1;6])
             ; InputRow ("????.#...#...", [4;1;1])
             ; InputRow ("????.######..#####.", [1;6;5])
             ; InputRow ("?###????????", [3;2;1])
             ]

let spring_char = function
  | Unknown -> '?'
  | Working -> '.'
  | Broken  -> '#'

(* explode and implode definitions from
 * https://caml.inria.fr/pub/old_caml_site/Examples/oc/basics/explode.ml
 *)
let explode s =
  let rec expl i l =
    if i < 0 then l else
      expl (i-1) (s.[i] :: l) in
  expl (String.length s - 1) []

let implode l =
  let result = Bytes.create (List.length l) in
  let rec imp i = function
    | [] -> String.of_bytes result
    | c :: l -> Bytes.set result i c; imp (i+1) l in
  imp 0 l

let print_springlist l =
  print_string (implode (List.map ~f:spring_char l))

let parse_input_str ir =
  let parse_char = function
    | '?' -> Unknown
    | '.' -> Working
    | '#' -> Broken
    | _ -> failwith "OH NO" in
  List.map ~f:parse_char (explode ir)

let rec parse_inputs = function
  | [] -> []
  | InputRow (s,lens)::tl ->
      Row (parse_input_str s, lens) :: parse_inputs tl

let rec print_inputs = function
  | [] -> ()
  | InputRow (s,lens)::tl ->
      print_newline (print_string s);
      print_inputs tl

let rec print_lens = function
  | [] -> print_string "\t"
  | l1 :: l2 :: [] ->
      print_int l1;
      print_string ",";
      print_int l2;
      print_string "\t"
  | len :: lens ->
      print_int len;
      print_string ",";
      print_lens lens

let rec print_rows = function
  | [] -> ()
  | Row (sprs, lens) :: rows ->
      print_newline(
        print_lens lens;
        print_springlist sprs
      );
      print_rows rows

let rec strip_front = function
  | [] -> []
  | Working :: sprs -> strip_front sprs
  | sprs -> sprs

let try_match n sprs =
  let[@tail_mod_cons] rec tm n sprs =
    if n == 0 then match sprs with
    | [] -> Some []
    | Working :: _ -> Some sprs
    | Broken :: _ -> None
    | _ -> failwith "OH NO"
    else match sprs with
    | [] -> None
    | Working :: sprs -> None
    | Broken :: sprs -> tm (n-1) sprs
    | _ -> failwith "OH NO"
  in tm n (strip_front sprs)

let[@tail_mod_cons] rec all_working = function
  | [] -> true
  | Working :: sprs -> all_working sprs
  | _ -> false

let[@tail_mod_cons] rec try_matches ns sprs =
  match ns with
  | [] -> all_working sprs
  | n :: ns ->
      match try_match n sprs with
      | None -> false
      | Some sprs -> try_matches ns sprs

let cons_all spr ls =
  let rec ca acc = function
    | [] -> acc
    | hd :: tl -> ca ((spr::hd)::acc) tl
  in ca [] ls

let[@tail_mod_cons] rec union l1 l2 =
  match l1 with
  | [] -> l2
  | hd::tl -> union tl (hd::l2)

let rec gen_springs = function
  | [] -> [[]]
  | Unknown :: sprs ->
      let rest = gen_springs sprs in
      union (cons_all Working rest) (cons_all Broken rest)
  | spr :: sprs -> cons_all spr (gen_springs sprs)

let count_ways (Row (sprs, lens)) =
  let rec count_true acc = function
    | [] -> acc
    | spr :: sprs ->
        if try_matches lens spr
        then count_true (acc+1) sprs
        else count_true acc sprs
  in
  let s' = gen_springs sprs in
  count_true 0 s'

let rows = parse_inputs inputs

let do_row (Row (sprs, lens)) =
  let rec one acc = function
    | [] -> ()
    | sprs :: sprss ->
        let good = try_matches lens sprs in
        if good then begin
          print_newline(print_string " > "; print_springlist sprs);
          one (acc+1) sprss
        end else
          one acc sprss
  in
  print_newline(print_string "   "; print_springlist sprs);
  one 0 (gen_springs sprs);
  print_newline(print_string "----------")

let read_rows maybe_file =
  let ic =
    match maybe_file with
    | Some path -> open_in path
    | None -> stdin
  in let rec rr acc =
    match input_line ic with
    | None -> acc
    | Some line ->
        match String.split_on_char ~sep:' ' line with
        | s :: l :: [] ->
            let lens = String.split_on_char ~sep:',' l in
            rr (Row (parse_input_str s, List.map ~f:int_of_string lens) :: acc)
        | _ -> failwith "OH NO"
  in rr []

let main () =
  let rows = read_rows None in
  let rec do_rows acc = function
    | [] -> acc
    | r :: rows -> do_rows (acc+(count_ways r)) rows
  in
  print_newline(print_int(do_rows 0 rows))
  (*
  let wayss = List.map ~f:count_ways rows in
  print_newline (print_int (List.fold_left ~f:(+) ~init:0 wayss))
  *)

let () = main ()
