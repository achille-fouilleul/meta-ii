open Printf

module LabelMap = Map.Make(String)

let f_debug = false;;

let instrs, label_map, start_label =
  let start_label_ref = ref "" in
  let map = ref LabelMap.empty in
  let i = ref 0 in
  let f = open_in(Sys.argv.(1)) in
  let rec loop() =
    let line = input_line f in
    let s = String.trim line in
    if line.[0] <> ' ' then begin
      map := LabelMap.add s !i !map;
      loop()
    end else begin
      let mnemo, operand =
        try
          let i = String.index s ' ' in
          let n = String.length s in
          let mnemo = String.sub s 0 i in
          let operand = String.sub s (i + 1) (n - (i + 1)) in
          (mnemo, String.trim operand)
        with Not_found -> (s, "")
      in
      match mnemo, operand with
      | "ADR", name -> start_label_ref := name; loop()
      | "END", "" -> close_in f; []
      | _ -> incr i; (mnemo, operand)::(loop())
    end
  in
  let instrs = Array.of_list(loop()) in
  instrs, !map, !start_label_ref
in
if f_debug then
  LabelMap.iter (fun k v -> eprintf "%s: %d\n" k v) label_map;

let switch = ref false in
let gn label_ref =
  M2io.print (M2io.gn label_ref) 
in
let ci() = M2io.print(M2io.get_token()) in
let cl s = M2io.print s in
let trace pc instr =
  match instr with
  | mnemo, "" -> eprintf "%d: %s\n" pc mnemo
  | mnemo, arg -> eprintf "%d: %s %s\n" pc mnemo arg
in
let int_of_label s =
  LabelMap.find s label_map
in
let unquote s =
  let n = String.length s in
  assert(String.get s 0 = '\'');
  assert(String.get s (n-1) = '\'');
  String.sub s 1 (n - 2)
in
let rec call pc =
  let label1 = ref "" in
  let label2 = ref "" in
  let rec loop pc =
    let instr = instrs.(pc) in
    if f_debug then
      trace pc instr;
    let next = pc + 1 in
    let pc' =
      match instr with
      | "BE", "" ->
        if not(!switch) then
          failwith "error";
        next
      | "BF", name ->
        if not(!switch) then int_of_label name else next
      | "BT", name ->
        if !switch then int_of_label name else next
      | "CI", "" -> ci(); next
      | "CL", s -> cl (unquote s); next
      | "CLL", name -> call(int_of_label name); next
      | "GN1", "" -> gn label1; next
      | "GN2", "" -> gn label2; next
      | "ID", "" -> switch := M2io.id(); next
      | "LB", "" -> M2io.lb(); next
      | "OUT", "" -> M2io.out(); next
      | "R", "" -> -1
      | "SET", "" -> switch := true; next
      | "SR", "" -> switch := M2io.sr(); next
      | "TST", s -> switch := M2io.tst (unquote s); next
      | mnemo, _ -> failwith ("invalid instruction: " ^ mnemo)
    in
    if pc' >= 0 then
      loop pc'
  in
  loop pc
in
call (int_of_label start_label)

