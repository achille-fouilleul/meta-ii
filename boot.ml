let error() =
  let line, pos = M2io.get_position() in
  let line_str = string_of_int line in
  let pos_str = string_of_int pos in
  failwith ("Error at position " ^ line_str ^ ":" ^ pos_str)
in
let emit_instr instr =
  M2io.print instr;
  M2io.out()
in
let emit_instr_arg instr arg =
  M2io.print (instr ^ " " ^ arg);
  M2io.out()
in
let emit_label label =
  M2io.lb();
  M2io.print label;
  M2io.out()
in
let label1 = M2io.gn
in
let expect s =
  if not(M2io.tst s) then error()
in
let out1()  =
  match () with
  | _ when M2io.tst "*1" -> emit_instr "GN1"; true
  | _ when M2io.tst "*2" -> emit_instr "GN2"; true
  | _ when M2io.tst "*" -> emit_instr "CI"; true
  | _ when M2io.sr() ->
    emit_instr_arg "CL" (M2io.get_token());
    true
  | _ -> false
in
let output() =
  if (
    match () with
    | _ when M2io.tst ".OUT" ->
      expect "(";
      while out1() do () done;
      expect ")";
      true
    | _ when M2io.tst ".LABEL" ->
      emit_instr "LB";
      if not(out1()) then error();
      true
    | _ -> false
  ) then begin
    emit_instr "OUT";
    true
  end else false
in
let rec ex3() =
  let label_ref = ref "" in
  match () with
  | _ when M2io.id() ->
    emit_instr_arg "CLL" (M2io.get_token());
    true
  | _ when M2io.sr() ->
    emit_instr_arg "TST" (M2io.get_token());
    true
  | _ when M2io.tst ".ID" -> emit_instr "ID"; true
  | _ when M2io.tst ".NUMBER" -> emit_instr "NUM"; true
  | _ when M2io.tst ".STRING" -> emit_instr "SR"; true
  | _ when M2io.tst "(" ->
    if not(ex1()) then error();
    expect ")";
    true
  | _ when M2io.tst ".EMPTY" -> emit_instr "SET"; true
  | _ when M2io.tst "$" ->
    emit_label (label1 label_ref);
    if not(ex3()) then error();
    emit_instr_arg "BT" (label1 label_ref);
    emit_instr "SET";
    true
  | _ -> false
and ex2() =
  let label_ref = ref "" in
  if (
    if ex3() then begin
      emit_instr_arg "BF" (label1 label_ref);
      true
    end else output()
  ) then begin
    while (
      if ex3() then begin
        emit_instr "BE";
        true
      end else output()
    ) do () done;
    emit_label (label1 label_ref);
    true
  end else
    false
and ex1() =
  let label_ref = ref "" in
  if ex2() then begin
    while M2io.tst "/" do
      emit_instr_arg "BT" (label1 label_ref);
      if not(ex2()) then error()
    done;
    emit_label (label1 label_ref);
    true
  end else
    false
in
let st() =
  if M2io.id() then begin
    emit_label (M2io.get_token());
    expect "=";
    if not(ex1()) then error();
    expect ".,";
    emit_instr "R";
    true
  end else
    false
in
expect ".SYNTAX";
if M2io.id() then begin
  emit_instr_arg "ADR" (M2io.get_token());
  while st() do () done;
  expect ".END";
  emit_instr "END"
end else
  error()
