# Množenje pomoću sabiranja
.section .data
.section .text
.globl main

main: 
    movl $19, %eax      # prvi broj
    movl $25, %ebx      # drugi broj
    movl $0, %ecx       # proizvod
    jmp pomnozi;        # izvrši petlju (mislim da radi i bez ovoga)

pomnozi:
    addl %eax, %ecx     # uvećaj sumu za prvi broj
    subl $1, %ebx       # umanji brojač za 1

    cmpl $0, %ebx       # uporedi da li je brojač stigao do 0
    je kraj             # ako jeste, završi program

    jmp pomnozi         # ponovo izvrši petlju

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
