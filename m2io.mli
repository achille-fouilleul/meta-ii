(* input *)

val get_position : unit -> (int * int)
val get_token : unit -> string
val id : unit -> bool
val sr : unit -> bool
val tst : string -> bool

(* output *)

val set_output_counter : int -> unit
val print : string -> unit
val lb : unit -> unit
val out : unit -> unit
val gn : string ref -> string
