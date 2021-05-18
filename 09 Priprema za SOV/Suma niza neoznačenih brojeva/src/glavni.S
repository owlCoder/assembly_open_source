# PR55-2020 Danijel Jovanović
.section .data
    ispis1: .ascii "Unesite izraz: \0"
    ispis1_len = . - ispis1

    ispis2: .ascii "Suma brojeva u opsegu je manja.\n\0"
    ispis2_len = . - ispis2

    ispis3: .ascii "Suma brojeva van opsega je manja.\n\0"
    ispis3_len = . - ispis3

    ispis4: .ascii "Sume su jednake.\n\0"
    ispis4_len = . - ispis4

    ispis5: .ascii "Suma: 0x\0"
    ispis5_len = . - ispis5

    greska1: .ascii "GRESKA: Prekoracenje prilikom racunanja sume.\n\0"
    greska1_len = . - greska1

    greska2: .ascii "GRESKA: Problem prilikom konverzije brojeva.\n\0"
    greska2_len = . - greska2

    maks_stdin = 100 + 1
    unos:    .fill  maks_stdin, 1, 0

    suma_1:  .long 0
    suma_2:  .long 0

    sum_isp:  .fill 20, 1, 0

    greska:  .long 0
.section .text
.global main

main:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis1,      %ecx
    movl $ispis1_len, %edx
    int $0x80

    # ucitavanje unosa
    movl $3,          %eax
    movl $0,          %ebx
    leal unos,        %ecx
    movl $maks_stdin, %edx
    int $0x80

    # funkcija za obradu unosa
    pushl $suma_2
    pushl $suma_1
    pushl $greska
    pushl $unos
    call obradiUnos
    addl $16,         %esp

    # da li je doslo do greske
    cmpl $0,          greska
    je ispisiManjuSumu

    cmpl $1,          greska
    je printError1

    cmpl $2,          greska
    je printError2

printError1:
    movl $4,           %eax
    movl $1,           %ebx
    leal greska1,      %ecx
    movl $greska1_len, %edx
    int $0x80

    movl $1,           greska
    jmp kraj

printError2:
    movl $4,           %eax
    movl $1,           %ebx
    leal greska2,      %ecx
    movl $greska2_len, %edx
    int $0x80
    
    movl $1,           greska
    jmp kraj    

ispisiManjuSumu:   
    # sacuvaj sume u registre
    movl suma_1,      %eax
    movl suma_2,      %ebx

    cmpl %eax,        %ebx
    je jednake
    jb drugaManja
    ja prvaManja

jednake:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis4,      %ecx
    movl $ispis4_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_1 ili suma_2 kao parametar jer su obe sume iste
    pushl $16
    pushl $sum_isp
    pushl suma_1
    call konvertujUHeksaBroj
    addl $12,         %esp
    
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,      %ecx
    movl $20,         %edx
    int $0x80

    jmp kraj

prvaManja:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis2,      %ecx
    movl $ispis2_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_1 kao parametar
    pushl $16
    pushl $sum_isp
    pushl suma_1
    call konvertujUHeksaBroj
    addl $12,         %esp
    
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,      %ecx
    movl $20,         %edx
    int $0x80

    jmp kraj

drugaManja:
    movl $4,          %eax
    movl $1,          %ebx
    leal ispis3,      %ecx
    movl $ispis3_len, %edx
    int $0x80

    # ovde potprogram za konverziju broja u heksa decimalni
    # salje se suma_2 kao parametar
    pushl $16
    pushl $sum_isp
    pushl suma_2
    call konvertujUHeksaBroj
    addl $12,         %esp

    movl $4,          %eax
    movl $1,          %ebx
    leal ispis5,      %ecx
    movl $ispis5_len, %edx
    int $0x80

    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal sum_isp,     %ecx
    movl $20,         %edx
    int $0x80

kraj:
    movl $1,          %eax
    movl greska,      %ebx
    int $0x80