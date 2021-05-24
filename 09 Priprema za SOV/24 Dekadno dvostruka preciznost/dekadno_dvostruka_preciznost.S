# Napisati program za konverziju celog dekadnog broja u interni oblik u dvostrukoj
# preciznosti.

.section .data
    por1:    .ascii "Unesite dekadni broj: \0"
    p1_len = . - por1

    greska1: .ascii "GRESKA: Problem prilikom konverzije brojeva.\n\0"
    g1_len = . - greska1

    m_in = 50 + 1
    unos:    .fill  m_in, 1, 0

    broj:    .quad 0

    sum_isp: .fill 20, 1, 0
    greska:  .long 0
.section .text
.global main

main:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal por1,      %ecx
    movl $p1_len,   %edx
    int $0x80

    # unos stringa
    movl $3,        %eax
    movl $0,        %ebx
    leal unos,      %ecx
    movl $m_in,     %edx
    int $0x80

    movl $unos,     %esi
    cmpb $10,      (%esi)
    je greskaKonverzija

    xorl %eax,      %eax
    movl $10,       %ecx

konverzija:
    movb (%esi),    %bl
    cmpb $10,       %bl
    je kraj

    # ako je razmak preskacemo ga
    cmpb $' ',      %bl
    je dalje

    cmpb $'0',      %bl
    jb greskaKonverzija

    cmpb $'9',      %bl
    ja greskaKonverzija

    # ascii u broj
    subb $'0',      %bl
    mull %ecx
    addl %ebx,      %eax
    adcl $0,        %edx

dalje:  
    incl            %esi
    jmp konverzija

greskaKonverzija:
    # ispis greske
    movl $4,        %eax
    movl $1,        %ebx
    leal greska1,   %ecx
    movl $g1_len,   %edx
    int $0x80
    
    incl            greska
    jmp kraj

kraj:
    # sumiraj u broj
    movl %eax,      broj
    movl %ebx,      broj+4

    movl $1,        %eax
    movl greska,    %ebx
    int $0x80