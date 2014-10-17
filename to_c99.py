#! /usr/bin/env python3

import sys
import from_asm

def mkstr(s):
    assert (s[0], s[-1]) == ('\'', '\'')
    return '"{}"'.format(s[1:-1])

class C99:
    def __init__(self, entry, func_names):
        self.current_func = None
        self.func_names = func_names
        self.entry = entry

    def __call__(self, mnemo, arg=None):
        mth = getattr(self, mnemo)
        if arg is not None:
            mth(arg)
        else:
            mth()

    def label(self, name):
        if name in self.func_names:
            assert self.current_func is None
            print()
            if name == self.entry:
                print('bool {}(void)'.format(name))
            else:
                print('static bool {}(void)'.format(name))
            print('{')
            print('\tbool flag;')
            print('\tchar *label1 = NULL;')
            print('\tchar *label2 = NULL;')
            self.current_func = name
        else:
            print('{}:'.format(name))

    def ADR(self, arg):
        pass

    def TST(self, arg):
        print('\tflag = TST({});'.format(mkstr(arg)));

    def SR(self): print('\tflag = SR();')
    def ID(self): print('\tflag = ID();')

    def BF(self, arg):
        print('\tif (!flag) goto {};'.format(arg))

    def BT(self, arg):
        print('\tif (flag) goto {};'.format(arg))

    def CL(self, arg):
        print('\tCL({});'.format(mkstr(arg)))

    def CI(self): print('\tCI();')

    def OUT(self): print('\tOUT();')
    def LB(self): print('\tLB();')

    def R(self):
        assert self.current_func is not None
        print('\treturn flag;')
        print('}')
        self.current_func = None

    def BE(self):
        print('\tif (!flag) ERROR();')

    def CLL(self, arg):
        print('\tflag = {}();'.format(arg))

    def SET(self):
        print('\tflag = true;')

    def GN1(self):
        print('\tGN(&label1);')

def to_c99(reader):
    lines = list(reader.readlines())
    entry, func_names = from_asm.get_func_names(lines)
    out = C99(entry, func_names)

    print('#include <stdbool.h>')
    print('#include "support.h"')
    print('#ifndef NULL')
    print('# define NULL 0')
    print('#endif')
    for func in func_names:
        if func == entry:
            print('bool {}(void);'.format(func))
        else:
            print('static bool {}(void);'.format(func))

    for l in lines:
        if l.startswith(' '):
            mnemo, arg = from_asm.get_mnemo_arg(l)
            if mnemo == 'END':
                break;
            else:
                out(mnemo, arg)
        else:
            out.label(l.strip())

if __name__ == '__main__':
    to_c99(sys.stdin)
