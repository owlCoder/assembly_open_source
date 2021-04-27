# PR55-2020 Jovanovic Danijel
# Šifra za Instagram PSI-AR-G10

.section .data
    msg1:  .ascii "Unesite sifru: \0"
    msg1_len = . - msg1

    maks = 8 + 1

    unos: .fill maks, 1, 42

    uneto: .long 0

    uredu: .byte 0
    specijalni: .long 0

    unosPonovo: .ascii "Sifra ne ispunjava uslove.\n\n\0"
    unosPonovo_len = . - unosPonovo

    uspesno: .ascii "Sifra ispunjava sve kriterijume!\n\0"
    uspesno_len = . - uspesno
.section .text
.global main

sifra:
    pushl %ebp
    movl %esp, %ebp
    pushl %esi

init:
    movl 8(%ebp),     %esi

krajStringa:
    cmpb $10,      (%esi)
    je kriterijumi

specijalniZnak:
    cmpb $'!',     (%esi)
    je brojacUvecaj

    cmpb $'?',     (%esi)
     je brojacUvecaj

    cmpb $'$',     (%esi)
     je brojacUvecaj

    cmpb $'#',     (%esi)
    je brojacUvecaj

uvecajAdresu:
    incl           %esi
    jmp krajStringa

brojacUvecaj:
    incl specijalni
    jmp uvecajAdresu 

kriterijumi:
    cmpl $3,       specijalni
    jge vrati0
    jl vrati1

vrati0:
    movl $0,      %eax
    jmp kraj_pp

vrati1:
    movl $1,      %eax

kraj_pp:
    popl %esi
    movl %ebp,   %esp
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
    decl %eax

    cmpl $8,        %eax
    jl main

    pushl $unos
    call sifra
    addl $4,       %esp

    movl %eax,     uredu

sveOk:
    cmpb $0,       uredu
    je ispisiOkej
    jne main               # opet unesi

ispisiOkej:
     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal uspesno,   %ecx
    movl $uspesno,  %edx
    int $0x80

kraj:
    movl $1,        %eax
    movl $0,        %ebx
    int $0x80