# Oduzimanje neoznačenih brojeva sa prenosom
.section .data
    prvi:   .quad  0x8000
    drugi:  .quad  0x1
    greska: .byte 0
.section .text

.globl main

main:
    movb $0,      greska 
    movl prvi,    %eax
    subl drugi,   %eax
    movl prvi+4,  %edx
    sbbl drugi+4, %edx
    jnc kraj
    incb greska

kraj:
    movl $0, %eax
    movl $1, %ebx
    int $0x80

#(gdb) info register eax ebx ecx edx
# eax            0x7fff   32767     # rezultat oduzimanja
# ebx            0x0      0
# ecx            0x46910ec5       1183911621
# edx            0x0      0
