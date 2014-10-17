#!/bin/sh

set -e

rm -f *.asm
rm -f *.cm*
rm -f boot interp
rm -rf *.pyc *.pyo __pycache__
rm -f meta-ii-amd64 meta-ii-amd64.S
rm -f meta-ii-c99 meta-ii-c99.c

