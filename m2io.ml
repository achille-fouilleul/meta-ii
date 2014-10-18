(* input *)

let position = ref (1, 1);;

let get_position() = !position;;

let token = Buffer.create 0;;

let token_clear() =
  Buffer.clear token;;

let token_add c =
  Buffer.add_char token c;;

let get_token() =
  Buffer.contents token;;

let input_buf = Buffer.create 0;;

let peek k =
  while not(k < Buffer.length input_buf) do
    Buffer.add_char input_buf (input_char stdin)
  done;
  Buffer.nth input_buf k;;

let advance k =
  for i = 0 to k - 1 do
    let (line, col) = !position in
    position := 
      if peek i <> '\n' then
        (line, col + 1)
      else
        (line + 1, 1)
  done;
  let n = Buffer.length input_buf in
  let s = Buffer.sub input_buf k (n - k) in
  Buffer.clear input_buf;
  Buffer.add_string input_buf s;;

let del_space() =
  let rec loop i =
    let c = peek i in
    if c = ' ' || c = '\n' then
      loop(i + 1)
    else
      advance i
  in
  loop 0;;

let isalpha c = c >= 'A' && c <= 'Z';;

let isdigit c = c >= '0' && c <= '9';;

let id() =
  del_space();
  Buffer.clear token;
  let c = peek 0 in
  if isalpha c then begin
    token_add c;
    let rec loop i =
      let c = peek i in
      if isalpha c || isdigit c then begin
        token_add c;
        loop (i + 1)
      end else
        advance i
    in
    loop 1;
    true
  end else
    false;;

let sr() =
  del_space();
  Buffer.clear token;
  let c = peek 0 in
  if c = '\'' then begin
    token_add c;
    let rec loop i =
      let c = peek i in
      token_add c;
      if c <> '\'' then
        loop(i + 1)
      else
        advance(i + 1)
    in
    loop 1;
    true
  end else
    false;;

let tst s =
  del_space();
  Buffer.clear token;
  let n = String.length s in
  let rec loop i =
    if i = n then begin
      Buffer.add_string token s;
      advance n;
      true
    end else
      if peek i = s.[i] then begin
        loop(i + 1)
      end else
        false
  in
  loop 0;;

(* output *)

let current_col = ref 1;;
let output_col = ref 8;;

let set_output_counter n =
  output_col := n;;

let print s =
  while !current_col < !output_col do
    print_char ' ';
    incr current_col
  done;
  print_string s;
  current_col := !current_col + String.length s;;

let lb() =
  output_col := 1;;

let out() =
  print_newline();
  output_col := 8;
  current_col := 1;;

let ci() =
  print(get_token());;

let gn =
  let i = ref 0 in
  fun label_ref ->
    match !label_ref with
    | "" ->
      let name = "L" ^ (string_of_int !i) in
      incr i;
      label_ref := name;
      name
    | name -> name;;
