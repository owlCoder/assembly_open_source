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

    # koliko je znakova ucitano za prvi string  
    movl %eax,     ucitano_znakova_str1

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

    # koliko je znakova ucitano za drugi string  
    movl %eax,     ucitano_znakova_str2

pocetak_prvog_stringa:
    movl $S1,                    %esi

prebroj_S1:
    cmpl $S1+max_str, %esi # da li smo stigli do kraja stringa
    jb broj_pluseve
    ja pocetak_drugog_stringa

broj_pluseve:
    movb (%esi),    %dl # sačuvaj trenutni element u manji registar
    cmpb $'+',      %dl # da li je to znak + ?
    je pronadjenPlus
    jmp uvecaj_adresu_S1

pronadjenPlus:
    incl pluseva

uvecaj_adresu_S1:
    incl %esi
    jmp prebroj_S1

# drugi string
pocetak_drugog_stringa:
    movl $S2,                    %esi

prebroj_S2:
    cmpl $S2+max_str, %esi # da li smo stigli do kraja stringa
    jb broj_minuse
    ja uporedi_broj_pluseva_minusa

broj_minuse:
    movb (%esi),    %dl # sačuvaj trenutni element u manji registar
    cmpb $'-',      %dl # da li je to znak + ?
    je pronadjenMinus
    jmp uvecaj_adresu_S2

pronadjenMinus:
    incl minusa

uvecaj_adresu_S2:
    incl %esi           # char ima 1 bajt !
    jmp prebroj_S2

uporedi_broj_pluseva_minusa:
    movl pluseva, %eax # nema dva pristupa memoriji
    cmpl %eax, minusa
    jb manjeMinusa
    ja manjePluseva
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
