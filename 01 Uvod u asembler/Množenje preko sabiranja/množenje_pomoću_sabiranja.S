# Množenje pomoću sabiranja
.section .data
.section .text
.global main

main: 
    movl $5,    %eax    # prvi broj
    movl $-200, %ebx    # drugi broj
    movl $0,    %ecx    # proizvod

    cmpl %eax,  %ebx    # ako je drugi broj veci od prvog, zameni ih
    ja zameni
    jmp pomnozi;        # izvrši petlju (mislim da radi i bez ovoga)

zameni:
    xchgl %eax, %ebx

pomnozi:
    addl %eax, %ecx     # uvećaj sumu za prvi broj
    jo prekoracenje     # u slucaju da je doslo do prekoracenja

    subl $1, %ebx       # umanji brojač za 1

    cmpl $0, %ebx       # uporedi da li je brojač stigao do 0
    je kraj             # ako jeste, završi program

    jmp pomnozi         # ponovo izvrši petlju

prekoracenje:
    movl $-1,%eax       # -1 došlo je do prekoracenja

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
