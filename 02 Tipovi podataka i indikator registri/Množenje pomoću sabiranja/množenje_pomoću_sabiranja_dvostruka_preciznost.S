# 1. Množenje pomoću sabiranja dva (ne)označena broja u dvostrukoj preciznosti
.section .data
    prvi:   .quad  0xC
    drugi:  .quad  0x2
    greska: .byte  0x0
.section .text

.global main

main: 
    movl prvi,  %eax    # prvi broj
    movl drugi, %ebx    # drugi broj
    movl $0,    %ecx    # proizvod
    jmp pomnozi         # izvrši petlju (mislim da radi i bez ovoga)

pomnozi:
    addl %eax, %ecx     # uvećaj sumu za prvi broj
    subl $1, %ebx       # umanji brojač za 1

    cmpl $0, %ebx       # uporedi da li je brojač stigao do 0
    je kraj             # ako jeste, završi program

    adcl %eax, %ecx     # dodaj ako je došlo do prekoračenja

    jnc kraj            # sve okej
    incb greska         # došlo je do prekoračenja

    jmp pomnozi         # ponovo izvrši petlju

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
