# Interni u oktalni - razlomljeni broj
.section .data
    unos:    .float 0.456
    konvert: .fill 10, 1, 0
    n:       .long 10 # broj slobodnih mesta u stringu
    greska:  .long 0
.section .text
.global main

main:
    movl $8,          %ecx    # baza sistema
    movl $konvert,    %esi    # broj koji se konvertuje (string)
    movl $100000000,  %ebx    # konstanta skaliranja
    movl unos,        %eax    # broj koji se konvertuje

    andl %eax,        %eax
    jns i2o_nula

    movb $'-',       (%esi)
    incl              %esi
    decl              n
    negl              %eax

i2o_nula:
    cmpl $4,          n
    jl i2o_greska
    movb $'0',       (%esi)
    movb $'.',      1(%esi)
    addl $2,          %esi
    decl              n

i2o_cifra:
    decl              n
    cmpl $1,          n
    je i2o_term
    mull %ecx
    divl %ebx
    addb $'0',        %al
    movb %al,        (%esi)
    incl              %esi
    movl %edx,        %eax
    andl %eax,        %eax
    jnz i2o_cifra

i2o_term:
    movl $0,         (%esi)
    jmp kraj

i2o_greska:
    incl              greska

kraj:
    movl $1,          %eax
    movl greska,      %ebx 
    int $0x80