.section .data
    str_max = 40
    str:     .fill str_max, 1, 42  # 42 - ascii '*'
    unos:    .ascii "Unesite vase ime i prezime: "
    len = . - unos
    ispis:   .ascii "\nVase ime i prezime je: "
    len2 = . - ispis
    velicina: .long 0
.section .text

.global main

main:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    movl $unos,      %ecx
    movl $len,      %edx
    int $0x80

    movl $3,       %eax         # stdin
    movl $0,       %ebx         # tastatura
    leal str,      %ecx         # efektivna adresa
    movl $str_max, %edx         # adresa u registar
    int $0x80   

    movl %eax, velicina         # sacuvaj broj unetih

     # ispis
    movl $4,        %eax
    movl $1,        %ebx
    movl $ispis,    %ecx
    movl $len2,     %edx
    int $0x80
    
    # ispis
    movl $4,        %eax
    movl $1,        %ebx
    movl $str,      %ecx
    movl velicina,  %edx
    int $0x80

kraj:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
