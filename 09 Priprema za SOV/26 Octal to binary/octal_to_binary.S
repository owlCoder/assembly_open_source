# Napisati program u asembleru za konverziju celog oktalnog broja u znakovnom obliku u
# binarni broj u znakovnom obliku

.section .data
    m_in = 50 + 1
    
    por1: .ascii "Unesite broj u oktalnom formatu: \0"
    p1_len = . - por1

    greska1: .ascii "GRESKA: Problem prilikom konverzije.\n\0"
    g1_len = . - greska1

    greska2: .ascii "GRESKA: Prekoracenje odredista.\n\0"
    g2_len = . - greska2

    unos: .fill m_in, 1, 0

    binBroj:  .fill 25, 1, 0
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

    # maksimalni unosi oktalni broj od 8 cifara
    decl %eax
    cmpl $8,         %eax
    ja greskaOdredista

    leal unos,       %esi
    cmpb $10,       (%esi)
    je greskaKonverzija

    xorl %eax,       %eax
    movl $8,         %ecx
    leal binBroj,    %edi
    
pretvoriUBinarni:
    cmpb $10,        (%esi)
    je ispisBroja

    # proveri koji binarni broj se upisuje u (%edi)
    cmpb $'0',       (%esi)
    je upisiNuluBin

    cmpb $'1',       (%esi)
    je upisiJedanBin

    cmpb $'2',       (%esi)
    je upisiDvaBin

    cmpb $'3',       (%esi)
    je upisiTriBin

    cmpb $'4',       (%esi)
    je upisiCetiriBin

    cmpb $'5',       (%esi)
    je upisiPetBin

    cmpb $'6',       (%esi)
    je upisiSestBin

    cmpb $'7',       (%esi)
    je upisiSedamBin

    jmp greskaKonverzija

upisiNuluBin:
    movb $'0',       (%edi)
    movb $'0',      1(%edi)
    movb $'0',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiJedanBin:
    movb $'0',       (%edi)
    movb $'0',      1(%edi)
    movb $'1',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiDvaBin:
    movb $'0',       (%edi)
    movb $'1',      1(%edi)
    movb $'0',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiTriBin:
    movb $'0',       (%edi)
    movb $'1',      1(%edi)
    movb $'1',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiCetiriBin:
    movb $'1',       (%edi)
    movb $'0',      1(%edi)
    movb $'0',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiPetBin:
    movb $'1',       (%edi)
    movb $'0',      1(%edi)
    movb $'1',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiSestBin:
    movb $'1',       (%edi)
    movb $'1',      1(%edi)
    movb $'0',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

upisiSedamBin:
    movb $'1',       (%edi)
    movb $'1',      1(%edi)
    movb $'1',      2(%edi)
    addl $3,          %edi
    incl              %esi
    jmp pretvoriUBinarni

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

ispisBroja:
    movb $10,        (%edi)

    # ispis greske
    movl $4,          %eax
    movl $1,          %ebx
    leal binBroj,     %ecx
    movl $25,         %edx
    int $0x80

kraj:
    movl $1,          %eax
    movl greska,      %ebx
    int $0x80