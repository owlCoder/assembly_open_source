# Iskopirati sadržaj datoteke t12.S u novu datoteku t34.S. Potom prepraviti/reorganizovati kod u datoteci t34.S,
# tako da se za realizaciju traženog algoritma poređenja koristi (i poziva) potprogram,
# koji treba biti u skladu sa
# sledećom cdecl deklaracijom:
# void potprogram(unsigned char *s1, unsigned char *s2, char *r);
.section .data
    max_str = 20
    S1: .fill max_str, 1, 42
    S2: .fill max_str, 1, 42

    unos1str: .ascii "Unesite S1: \0"
    u1s_len = . - unos1str

    unos2str: .ascii "Unesite S2: \0"
    u2s_len = . - unos2str

    R: .byte -1
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

    pushl $R                # ubacivanje na stek
    pushl $S2               # ubacivanje na stek
    pushl $S1               # ubacivanje na stek
    call potprogram         # poziv potprograma

    movl %eax, R            # rezultat smesti u promenljivu R

kraj:
    movl $1, %eax
    movl R,  %ebx
    int $0x80
