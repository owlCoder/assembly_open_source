# PR55-2020 Jovanović Danijel

# Zadatak t12.S
# U datoteci t12.S realizovati asemblerski program koji će sa standardnog ulaza učitati dva stringa 
# (koji mogu imati do 20 karaktera) u promenljive S1 i S2 i potom postaviti 8-bitnu neoznačenu promenljivu R na
# vrednost:
# -> 1 ukoliko string S1 sadrži više znakova ’+’ nego što S2 ima znakova ’-’
# -> 2 ukoliko string S1 sadrži manje znakova ’+’ nego što S2 ima znakova ’-’
# -> 3 ukoliko string S1 sadrži isti broj znakova ’+’ kao što S2 ima znakova ’-’
# Putem odgovarajućeg sistemskog poziva program treba da vrati operativnom sistemu vrednost promenljive R.

# Primer interakcije sa programom:
# Unesite S1: srecno++ na testu
# Unesite S2: ^-^
.section .data
    max_str = 20
    S1: .fill max_str, 1, 42
    S2: .fill max_str, 1, 42

    unos1str: .ascii "Unesite S1: \0"
    u1s_len = . - unos1str

    unos2str: .ascii "Unesite S2: \0"
    u2s_len = . - unos2str

    R: .byte 0

    ucitano_znakova_str1: .long 0
    ucitano_znakova_str2: .long 0

    pluseva:              .long 0
    minusa:               .long 0
.section .text
.global main

main:
    # ispis prve poruke za unos stringa
    movl $4,       %eax
    movl $1,       %ebx
    leal unos1str, %ecx
    movl $u1s_len, %edx
    int $0x80

    # ucitavanje prvog stringa
    movl $3,       %eax
    movl $0,       %ebx
    leal S1,       %ecx
    movl $max_str, %edx
    int $0x80

    # ispis druge poruke za unos stringa
    movl $4,       %eax
    movl $1,       %ebx
    leal unos2str, %ecx
    movl $u2s_len, %edx
    int $0x80

    # ucitavanje drugog stringa
    movl $3,       %eax
    movl $0,       %ebx
    leal S2,       %ecx
    movl $max_str, %edx
    int $0x80

    # pozivanje potprograma za prebrojavanje znakova
    pushl $'+'
    pushl $S1
    call prebroji
    movl %eax, pluseva
    addl $8,      %esp # oslobadjanje steka

    pushl $'-'
    pushl $S2
    call prebroji
    movl %eax, minusa
    addl $8,      %esp # oslobadjanje steka

uporedi_broj_pluseva_minusa:
    movl pluseva, %eax # nema dva pristupa memoriji
    cmpl minusa,  %eax
    ja manjeMinusa
    jb manjePluseva
    je istiBroj

manjeMinusa:
    movl $1, R
    jmp kraj

manjePluseva:
    movl $2, R
    jmp kraj

istiBroj:
    movl $3, R

kraj:
    movl $1, %eax
    movl R,  %ebx # Putem odgovarajućeg sistemskog poziva program 
                  # treba da vrati operativnom sistemu vrednost promenljive R.
    int $0x80
