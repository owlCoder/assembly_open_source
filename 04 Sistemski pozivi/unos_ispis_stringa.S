# unos i ispis stringa

.section .data
    str_max = 40
    str:     .fill str_max, 1, 42  # 42 - ascii '*'
    velicina: .long 0
.section .text

.global main

main:
    movl $3,       %eax         # stdin
    movl $0,       %ebx         # tastatura
    leal str,      %ecx         # efektivna adresa
    movl $str_max, %edx         # adresa u registar
    int $0x80   

    movl %eax, velicina         # sacuvaj broj unetih

    # ispis
    movl $4,        %eax
    movl $1,        %ebx
    movl $str,      %ecx
    movl velicina, %edx
    int $0x80

kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
