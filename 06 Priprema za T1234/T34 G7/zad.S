# PR55-2020 Jovanovic Danijel
# Cezarova šifra PSI-AR-G7

.section .data
    msg1:  .ascii "Unesite string: \0"
    msg1_len = . - msg1

    msg2: .ascii "Sifrovano: \0"
    msg2_len = . - msg2

    maks = 50 + 1

    unos: .fill maks, 1, 42

    uneto: .long 0
.section .text
.global main

cezar:
    pushl           %ebp
    movl %esp,      %ebp
    pushl           %esi

init:
    movl 8(%ebp),   %esi

krajStringa:
    cmpb $10,      (%esi)
    je kraj_pp

daLiJeSlovo:
    cmpb $'A',     (%esi)
    jl uvecajAdresu

    cmpb $'Z',     (%esi)
    jle daLiJeIzmedjuxIz

    cmpb $'a',     (%esi)
    jl uvecajAdresu

    cmpb $'z',     (%esi)
    jle daLiJeIzmedjuxIz
    jg uvecajAdresu

daLiJeIzmedjuxIz:
    # velika slova
    cmpb $'X',    (%esi)
    jl dodaj3

    cmpb $'Z',    (%esi)
    jle oduzmi23
    
    cmpb $'x',    (%esi)
    jl dodaj3
    
    cmpb $'z',    (%esi)
    jle oduzmi23

dodaj3:
    addb $3,      (%esi)
    jmp uvecajAdresu
    
oduzmi23:
    subb $23,     (%esi)

uvecajAdresu:
    incl           %esi
    jmp krajStringa

kraj_pp:
    popl %esi
    movl %ebp,     %esp
    popl %ebp
    ret

main:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal msg1,      %ecx
    movl $msg1_len, %edx
    int $0x80

    # unos
    movl $3,        %eax
    movl $0,        %ebx
    leal unos,      %ecx
    movl $maks,     %edx
    int $0x80

    movl %eax,      uneto

    pushl $unos
    call cezar
    addl $4,        %esp

ispisModifikovanogStringa:
     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal msg2,      %ecx
    movl $msg2_len, %edx
    int $0x80

     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal unos,      %ecx
    movl uneto,     %edx
    int $0x80

kraj:
    movl $1,        %eax
    movl $0,        %ebx
    int $0x80