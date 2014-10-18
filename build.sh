#!/bin/sh

set -e

./clean.sh

mlc=ocamlc

$mlc -c m2io.mli
$mlc -o interp m2io.ml interp.ml
$mlc -o boot m2io.ml boot.ml

ocamlrun boot < meta-ii.txt > meta-ii.asm
ocamlrun interp meta-ii.asm < meta-ii.txt > /tmp/meta-ii.asm

cmp meta-ii.asm /tmp/meta-ii.asm

cflags="-std=c99 -g -W -Wall -Wextra"

python3 to_c99.py < meta-ii.asm > meta-ii-c99.c
cc $cflags -Wno-unused-label -Wno-unused-variable main.c meta-ii-c99.c -o meta-ii-c99
./meta-ii-c99 < meta-ii.txt > /tmp/meta-ii.asm
cmp meta-ii.asm /tmp/meta-ii.asm

if test "`arch`" = x86_64; then
  python3 to_amd64.py < meta-ii.asm > meta-ii-amd64.S
  cc $cflags main.c meta-ii-amd64.S -o meta-ii-amd64
  ./meta-ii-amd64 < meta-ii.txt > /tmp/meta-ii.asm
  cmp meta-ii.asm /tmp/meta-ii.asm
fi
