# autor: Danijel Jovanović PR55-2020
.section .data
    maks_unos = 50 + 1

    prompt_1: .ascii "Unesite string: \0"
    prompt_1_len  = . - prompt_1

    prompt_2: .ascii "Enkodovan string: \0"
    prompt_2_len = . - prompt_2

    unos: .fill maks_unos, 1, 42

    unetoZnakova: .long 0

    brojIzmena:   .long 0
.section .text
.global main

main:
    # ispis poruke za unos
    movl $4,            %eax
    movl $1,            %ebx
    leal prompt_1,      %ecx
    movl $prompt_1_len, %edx
    int $0x80

    # ucitavanje stringa
    movl $3,            %eax
    movl $0,            %ebx
    leal unos,          %ecx
    movl $maks_unos,    %edx
    int $0x80 

    movl %eax,          unetoZnakova # optimizacije radi se cuva broj unetih char

    # priprema za poziv potprograma
    pushl $unos
    call  Rot13
    addl  $4,           %esp         # oslobadjanje steka
    movl  %eax,         brojIzmena

enkodovan_ispis:
    # ispis poruke za enkodovano
    movl $4,            %eax
    movl $1,            %ebx
    leal prompt_2,      %ecx
    movl $prompt_2_len, %edx
    int $0x80

    # enkodovan string
    movl $4,            %eax
    movl $1,            %ebx
    leal unos,          %ecx
    movl unetoZnakova,  %edx
    int $0x80

kraj:
    movl $1,            %eax
    movl brojIzmena,    %ebx
    int $0x80
