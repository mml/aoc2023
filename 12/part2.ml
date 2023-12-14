open In_channel
open Map
(** Notes of how I thought this would work.  See the other comment down by
    make_counter to see what I really did.

    ------8<------8<------8<------8<------8<------8<------8<------8<------8<

    Explanation of how slop could work...

    Given
    ".??..??...?##..??..??...?##..??..??...?##..??..??...?##..??..??...?##."
    [1;1;3;1;1;3;1;1;3;1;1;3;1;1;3]
  
    The string has length 70 and the list totals 25.  But groups of broken
    springs must be separated by at least 1 operational spring.  To simplify
    this, let's just say that each run of N broken springs is actually a run of
    N+1: N broken springs and a working spring.  And then we'll make our string
    template one longer by adding a "." at the end.

    ".??..??...?##..??..??...?##..??..??...?##..??..??...?##..??..??...?##.."
    [2;2;4;2;2;4;2;2;4;2;2;4;2;2;4]
    31

    So that means we have to cram 40 characters into a 71-character template.
    Meaning there is 31 characters of slop.
    This means that the first spring must go somewhere between (0..31).  Only
    some of those are places where a spring could go.  For each of those, we get
    back a triple of (string, string, slop).

    The first one would be (".#.", "..??[...]", 30), which means that with 30
    characters of slop remaining, we're looking now for strings starting at the
    indicated unused suffix string.

    We could then feed these values into the same function...

    "..??...?##..??..??...?##..??..??...?##..??..??...?##..??..??...?##.."
    [2;4;2;2;4;2;2;4;2;2;4;2;2;4]

    and in this case the first value we'd get back out would be
    ("..#.", "...?##[...]", 28)

   *)

type spring = Unknown | Working | Broken
type row = Row of spring list * int list

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

let spring_char = function
  | Unknown -> '?'
  | Working -> '.'
  | Broken  -> '#'

let parse_input_str ir =
  let parse_char = function
    | '?' -> Unknown
    | '.' -> Working
    | '#' -> Broken
    | _ -> failwith "OH NO CANT PARSE" in
  List.map parse_char (explode ir)
  
let tweak_tpl tpl = tpl @ [Working]

let tweak_runs = List.map ((+) 1)

let tweak_row (Row (sprs, lens)) =
  Row (tweak_tpl sprs, tweak_runs lens)

let find_slop tpl runs =
  List.fold_left (-) (List.length tpl) runs

let empty = []
let single pos dslop count = [((pos,dslop),count)]
let rec merge a b =
  match b with
  | [] -> a
  | (key, c1) :: tl ->
      match List.assoc_opt key a with
      | None -> (key, c1)::(merge a tl)
      | Some c2 -> (key, c1+c2)::(merge (List.remove_assoc key a) tl)

let rec assert_no_dups = function
  | [] -> ()
  | (k,v) :: tl ->
      match List.assoc_opt k tl with
      | None -> assert_no_dups tl
      | Some x -> 
          failwith (Printf.sprintf "has a dup (%i,%i)" (fst k) (snd k))

(**
   This is essentially a fancy dynamic programming approach.  Compared to
   part1, there are a lot of changes.

   1. Instead of actually generating strings, we just keep track of how long the strings would be.
   2. Instead of passing around ever-shortening linked lists, I switched to an
   array and used indices.  This should improve memory locality a bit, but it
   may not be necessary.
   3. Since we're only managing counts, we can merge whatever count-structures
   we use at each stage instead of appending gigantic lists together.  This
   keeps data structure size small.  This example just uses an alist, which
   turns out to be more than adequate.
   4. Instead of passing in a "slop budget", the return value includes how much
   slop has been consumed (dslop).  However, measuring the slop consumed turns
   out to be unimportant.  I never implemented the code which filters out
   results that use up "too much" slop.  I don't quite grok why this works, but
   the answer is correct.
   5. The nature of this approach creates the possibility of re-evaluating `f`
   over the same arguments repeatedly.  So I basically create a specialized
   function for each template, which closes over both the array and a hash
   table for caching results.
   *)
let make_counter tpl =
  let len = List.length tpl in
  let h = Hashtbl.create 1000000 in
  let ta = Array.init len (fun i -> List.nth tpl i) in
  let rec g_in runlen pos dslop =
    if runlen == 0 then single pos dslop 1
    else if pos >= len then empty
    else if runlen == 1 then match ta.(pos) with
    | (Working | Unknown) -> g_in (runlen-1) (pos+1) dslop
    | Broken -> empty
    else match ta.(pos) with
    | (Broken | Unknown) -> g_in (runlen-1) (pos+1) dslop
    | Working -> empty
  and zero pos dslop =
    if pos >= len then single pos dslop 1
    else match ta.(pos) with
    | Broken -> empty
    | (Working | Unknown) -> zero (pos+1) dslop
  and g runlen pos dslop =
    if runlen == 0 then zero pos dslop
    else if pos >= len then empty
    else if runlen == 1 then failwith "OH NO (f X 1) NO WORKIE"
    else match ta.(pos) with
    | Working -> g runlen (pos+1) (dslop+1)
    | Broken -> g_in (runlen-1) (pos+1) dslop
    | Unknown -> (
        merge
          (g runlen (pos+1) (dslop+1))
          (g_in (runlen-1) (pos+1) dslop)
    )
  and f offset runlen = g runlen offset 0
  in fun offset runlen ->
    match Hashtbl.find_opt h (offset,runlen) with
    | None ->
        let it = f offset runlen in
        Hashtbl.add h (offset,runlen) it;
        it
    | Some x -> x

let supercount tpl runs =
  let f = make_counter tpl in
  let rec count_all cnts ns =
    (* assert_no_dups cnts; *)
    match ns with
    | [] -> recur 0 cnts
    | n :: ns ->
        count_all (recur n cnts) ns
  and recur n cnts =
    List.fold_left merge empty (
      List.map (
        fun ((pos,dslop),count) ->
          List.map (
            fun ((p,d),c) ->
              let c' = count*c in
              if c' < 0 then failwith "OVERFLOW"
              else ((p,dslop+d),count*c)) (f pos n)
      ) cnts
    )
  in
  count_all (f 0 (List.hd runs)) (List.tl runs)

let join_copies c l =
  let rec jc = function
    | 0 -> []
    | 1 -> l
    | n -> l @ c::(jc (n-1))
  in jc

let copies l =
  let rec c = function
    | 0 -> []
    | 1 -> l
    | n -> l @ (c (n-1))
  in c

let expand_row (Row (sprs, lens)) =
  Row (join_copies Unknown sprs 5, copies lens 5)

let read_rows maybe_file =
  let ic =
    match maybe_file with
    | Some path -> open_in path
    | None -> stdin
  in let rec rr acc =
    match input_line ic with
    | None -> List.rev acc
    | Some line ->
        match String.split_on_char ' ' line with
        | s :: l :: [] ->
            let lens = String.split_on_char ',' l in
            rr (expand_row (Row (parse_input_str s, List.map int_of_string lens)) :: acc)
        | _ -> failwith "OH NO CANT EXPAND"
  in rr []

let count_main inp =
  let rows = read_rows inp in
  let rows = List.map tweak_row rows in
  let tot = ref 0 in
  List.iter (
    fun (Row (sprs, lens)) ->
      Printf.eprintf "%s\n" (implode (List.map spring_char sprs));
      let xs = supercount sprs lens in
      List.iter (
        fun ((p,d),c) ->
          Printf.eprintf "(%i,%i) -> %i\n" p d c;
          tot := !tot + c
      ) xs
  ) rows;
  print_newline(print_int !tot)

let () =
  Printf.eprintf("--- START ---\n");
  if String.ends_with ~suffix:"utop" Sys.argv.(0) then ()
  else if 1 == (Array.length Sys.argv) then ()
  else match Sys.argv.(1) with
  | "-" -> count_main None
  | f -> count_main (Some f)
