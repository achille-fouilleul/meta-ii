meta-ii
=======

This is an implementation of the META II metacompiler (cf. <http://en.wikipedia.org/wiki/META_II>).

The syntax.txt file was extracted directly from Schorre's 1964 paper.

First, boot.ml translates the syntax.txt file into a program for the META II virtual machine.
Then, interp.ml interprets the program: when fed with syntax.txt, it should produce the same program as its output.

Two Python scripts have been added:
* to_c99.py: translates META II VM programs into C99 code.
* to_amd64.py: translates META II VM programs into X86-64 assembly.
