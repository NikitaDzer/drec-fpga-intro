.text
.globl _start
.globl _finish
.globl main

_start:
    li a1, 1
    sltu a1, a0, a1
    sltu a1, a1, a0
    call main

_finish:
    j _finish
