.section .data
.section .text
.globl main

main: 
    movl $0, %eax       # podesi vrednost sume na 0
    movl $1, %ebx       # podesi vrednost brojača na 1
    jmp sumiranje;      # izvrši petlju (mislim da radi i bez ovoga)

sumiranje:
    cmpl $10, %ebx      # uporedi da li je brojač stigao do 10
    je kraj             # ako jeste, završi program

    addl %ebx, %eax     # dodaj brojač na sumu
    addl $1, %ebx       # brojač uvećaj za 1
    jmp sumiranje       # ponovo izvrši petlju

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
