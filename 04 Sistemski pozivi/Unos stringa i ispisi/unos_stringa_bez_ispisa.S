.section .data
    str_max = 40
    str:     .fill str_max, 1, 42  # 42 - ascii '*'
.section .text
.global main

main:
    movl $3,       %eax         # stdin
    movl $0,       %ebx         # tastatura
    leal str,      %ecx         # efektivna adresa
    movl $str_max, %edx         # adresa u registar
    int $0x80   

kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
