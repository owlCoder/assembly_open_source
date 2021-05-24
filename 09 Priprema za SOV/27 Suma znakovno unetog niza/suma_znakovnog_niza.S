# 747#$[527829]{#3d}[432]; sumu najvecih brojeva iz [ ]; Tu sumu ispisati na ekran

.section .data
    m_in = 50 + 1
    
    por1: .ascii "Unesite string: \0"
    p1_len = . - por1

    greska1: .ascii "GRESKA: Problem prilikom konverzije.\n\0"
    g1_len = . - greska1

    greska2: .ascii "GRESKA: Prekoracenje odredista.\n\0"
    g2_len = . - greska2

    unos: .fill m_in, 1, 0
    nl: .ascii "\n\0"

    s_ispis:   .fill 25, 1, 0

    cifraStr:  .fill 25, 1, 0
    suma:      .long 0
    greska: .long 0
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

    # maksimalni unos je 50 cifara
    decl %eax
    cmpl $50,       %eax
    ja greskaOdredista

    leal unos,       %esi
    cmpb $10,       (%esi)
    je greskaKonverzija


pocetak:
    leal cifraStr,   %edi
    
krajStringa:
    cmpb $10,       (%esi)
    je ispisSume

    pronadjiOtvorenuUglastu:
        cmpb $'[',  (%esi)
        jne dalje

        incl %esi

        isCifra:
            cmpb $'0',     (%esi)
            jb greskaKonverzija

            cmpb $'9',     (%esi)
            ja greskaKonverzija

            # onda je cifra, upiši je u temp niz
            movb (%esi),    %bl
            movb  %bl,     (%edi)
            incl %esi
            incl %edi

            # da li je kraj unosa niza u [ ]
            cmpb $']',     (%esi)
            je pronadjiNajvecuCifru
            jmp isCifra

pronadjiNajvecuCifru:
    # vrati se na početak stringa
    leal cifraStr,          %edi

    # prvi u nizu je trenutni max
    movb (%edi),            %cl
    incl  %edi

    traziMax:
        cmpb $0,           (%edi)
        je anulirajPomocniNiz

        cmpb (%edi),        %cl    # ako je trenutna cifra veća od max
        jb promeniMax         

        incl  %edi
        jmp traziMax    

    promeniMax:  
        movb (%edi),        %cl
        incl  %edi
        jmp traziMax
    
anulirajPomocniNiz:
    leal cifraStr,         %edi

    # u %cl se nalazi najveca cifra
    # dodaj je u sumu
    subb $'0',         %cl
    addb %cl,          suma
    xorl %ecx,         %ecx
    
    anuliraj:
        cmpb $0,          (%edi)
        jne prepisiNulom
        je naPocetak

    prepisiNulom:
        movb $0,          (%edi)
        incl %edi
        jmp anuliraj

naPocetak:
    incl %esi
    jmp pocetak

dalje:
    incl %esi
    jmp krajStringa

greskaKonverzija:
    # ispis greske
    movl $4,          %eax
    movl $1,          %ebx
    leal greska1,     %ecx
    movl $g1_len,     %edx
    int $0x80
    
    incl              greska
    jmp kraj

greskaOdredista:
    # ispis greske
    movl $4,          %eax
    movl $1,          %ebx
    leal greska2,     %ecx
    movl $g2_len,     %edx
    int $0x80
    
    incl              greska
    jmp kraj

ispisSume:
    movl suma,        %eax
    movl $10,         %ecx
    leal s_ispis,     %esi

    brojUString:
        andl %eax,    %eax
        jz obrni

        xorl %edx,    %edx
        divl %ecx

        addb $'0',    %dl
        movb %dl,    (%esi)
        incl %esi
        jmp brojUString

    obrni:
        decl %esi
        leal s_ispis,     %edi

    invertuj:
        cmpl %edi,    %esi
        jbe ispisSumiranog

        movb (%esi),  %bl
        movb (%edi),  %bh

        movb  %bh,   (%esi)
        movb  %bl,   (%edi)

        decl %esi
        incl %edi
        jmp invertuj

ispisSumiranog:
    # ispis sume
    movl $4,          %eax
    movl $1,          %ebx
    leal s_ispis,     %ecx
    movl $25,         %edx
    int $0x80

    # novi red
    movl $4,          %eax
    movl $1,          %ebx
    leal nl,          %ecx
    movl $2,          %edx
    int $0x80

kraj:
    movl $1,          %eax
    movl greska,      %ebx
    int $0x80