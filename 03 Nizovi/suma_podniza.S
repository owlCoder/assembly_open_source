.section .data
    suma: .long 0
    niz_l: .long 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    min_limit = 3
    max_limit = 8
.section .text
.global main

main:
    movl $min_limit, %esi    # indeks od kog pocinjemo
    movl $max_limit, %ebx    # kraj podniza
    movl $0,         %eax    # registar sume

sumiranje:
    addl niz_l(, %esi, 4), %eax
    incl %esi               # sledeci indeks

    cmpl %ebx, %esi         # kraj podniza?
    jns kraj

    jmp sumiranje

kraj:
    movl %eax, suma         # iz registra u sumu
    movl $1, %eax
    movl $0, %ebx
    int $0x80
