#! /usr/bin/env python3

import sys
import from_asm

strtab = {}

def mkstr(s):
    assert (s[0], s[-1]) == ('\'', '\'')
    k = s[1:-1]
    v = strtab.get(k)
    if v is None:
        v = '.LC{}'.format(len(strtab))
        strtab[k] = v
    return v

def instr(s):
    print('\t' + s)

class Amd64:
    def __init__(self, func_names):
        self.current_func = None
        self.func_names = func_names

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
            instr('.type {}, @function'.format(name))
            print('{}:'.format(name))
            # prologue
            instr('.cfi_startproc')
            instr('sub $24, %rsp')
            instr('.cfi_def_cfa_offset 32')
            instr('movq $0, (%rsp)') # init label1
            instr('movq $0, 8(%rsp)') # init label2
            self.current_func = name
        else:
            print('.L{}:'.format(name))

    def call(self, name):
        instr('call {}'.format(name))

    def store_flag(self, source):
        instr('movb {}, 16(%rsp)'.format(source))

    def test_flag(self):
        instr('cmpb $0, 16(%rsp)')

    def load_flag(self, dest):
        instr('movb 16(%rsp), {}'.format(dest))

    def ADR(self, arg):
        pass

    def CLL(self, arg):
        self.call(arg)
        self.store_flag('%al')

    def R(self):
        assert self.current_func is not None
        self.load_flag('%al')
        # epilogue
        instr('add $24, %rsp')
        instr('.cfi_def_cfa_offset 8')
        instr('ret')
        instr('.cfi_endproc')
        instr('.size {0}, .-{0}'.format(self.current_func))
        self.current_func = None

    def SET(self):
        self.store_flag('$1')

    def BT(self, arg):
        self.test_flag()
        instr('jnz .L{}'.format(arg))

    def BF(self, arg):
        self.test_flag()
        instr('jz .L{}'.format(arg))

    def BE(self):
        self.test_flag()
        instr('jnz 1f')
        instr('call ERROR')
        print('1:')

    def TST(self, arg):
        instr('movl ${}, %edi'.format(mkstr(arg)))
        self.call('TST')
        self.store_flag('%al')

    def CL(self, arg):
        instr('movl ${}, %edi'.format(mkstr(arg)))
        self.call('CL')

    def OUT(self): self.call('OUT')
    def LB(self): self.call('LB')
    def CI(self): self.call('CI')

    def ID(self):
        self.call('ID')
        self.store_flag('%al')

    def SR(self):
        self.call('SR')
        self.store_flag('%al')

    def GN1(self):
        instr('mov %rsp, %rdi')
        self.call('GN')

    def GN2(self):
        instr('lea 8(%rsp), %rdi')
        self.call('GN')

def to_amd64(reader):

    lines = list(reader.readlines())

    entry, func_names = from_asm.get_func_names(lines)
    out = Amd64(func_names)

    instr('.text')
    instr('.global {}'.format(entry))

    for l in lines:
        if l.startswith(' '):
            mnemo, arg = from_asm.get_mnemo_arg(l)
            if arg is not None:
                s = '{} {}'.format(mnemo, arg)
            else:
                s = mnemo
            instr('/* {} */'.format(s))
            if mnemo == 'END':
                break
            else:
                out(mnemo, arg)
        else:
            out.label(l.strip())


    print('\t.section .rodata.str1.1,"aMS",@progbits,1')
    for k, v in strtab.items():
        print('{}:'.format(v))
        instr('.string "{}"'.format(k))

if __name__ == '__main__':
    to_amd64(sys.stdin)
