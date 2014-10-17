#!/bin/sh

set -e

./clean.sh

mlc=ocamlc

$mlc -c m2io.mli
$mlc -o interp m2io.ml interp.ml
$mlc -o boot m2io.ml boot.ml

ocamlrun boot < meta-ii.txt > meta-ii-1.asm

ocamlrun interp meta-ii-1.asm < meta-ii.txt > meta-ii-2.asm

cmp meta-ii-1.asm meta-ii-2.asm

cflags="-std=c99 -g -O2 -W -Wall -Wextra"

if test "`arch`" = x86_64; then
  python3 to_amd64.py < meta-ii-1.asm > meta-ii-amd64.S
  cc $cflags main.c meta-ii-amd64.S -o meta-ii-amd64
  ./meta-ii-amd64 < meta-ii.txt > meta-ii-3.asm
  cmp meta-ii-1.asm meta-ii-3.asm
fi

python3 to_c99.py < meta-ii-1.asm > meta-ii-c99.c
cc $cflags -Wno-unused-label -Wno-unused-variable main.c meta-ii-c99.c -o meta-ii-c99
./meta-ii-c99 < meta-ii.txt > meta-ii-4.asm
cmp meta-ii-1.asm meta-ii-4.asm
