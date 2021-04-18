#  Zbir prvih n brojeva
.section .data
.section .text
.global main

main: 
    movl $0, %eax       # podesi vrednost sume na 0
    movl $0, %ebx       # podesi vrednost brojača na 0
    jmp sumiranje;      # izvrši petlju (mislim da radi i bez ovoga)

sumiranje:
    addl $1,   %ebx     # brojač uvećaj za 1
    addl %ebx, %eax     # dodaj brojač na sumu
    jc prekoracenje     # u slucaju da je doslo do prekoracenja, 
                        # carry jer su prirodni brojevi

    cmpl $10,  %ebx     # uporedi da li je brojač stigao do 10
    je kraj             # ako jeste, završi program

    jmp sumiranje       # ponovo izvrši petlju

prekoracenje:
    movl $-1,  %eax     # -1 indikator prekoracenja

kraj: 
    movl $1, %eax       # flush registrija %eax
    movl $0, %ebx       # flush registrija %ebx
    int $0x80           # sistemski poziv
