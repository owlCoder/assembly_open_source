# Uneses sa tastature niz karaktera i da sumiras sve NUMERICKE karaktere ciji 
# ces konacan rezultat ispisati na ekran.
.section .data
    por1: .ascii "Unesite string: \0"
    p1_len = . - por1

    por2:    .ascii "Niste uneli nijedan numericki karakter!\n\0"
    p2_len = . - por2

    por3:   .ascii "Suma numerckih karaktera iznosi: \0"
    p3_len = . - por3

    por4:   .ascii "Nema dovoljno prostora u odredisnom stringu!\n\0"
    p4_len = . - por4
    m_in = 50

    unos: .fill m_in, 1, 0

    suma:       .long 0
    s_ispis:    .fill 10, 1, 0
    n:          .long 10 

    nl:         .ascii "\n\0" 
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

    # da li je unet prazan string ?
    movl $unos,     %esi
    cmpb $10,      (%esi)
    je ispisGreske

    # nije unet prazan string, ako je cifra, a nije \n, 
    # pretvori u broj i dodaj na sumu
    xorl %eax,      %eax

krajStringa:
    cmpb $10,      (%esi)
    je konvertovanjeSume

    cmpb $'0',     (%esi)
    jb dalje

    cmpb $'9',     (%esi)
    ja dalje

    # broj je numericka cifra
    movb (%esi),    %bl
    subb  $'0',     %bl
    addl  %ebx,     %eax
    # jc prekoracenje

dalje:
    incl            %esi
    jmp krajStringa

konvertovanjeSume:
    movl %eax,      suma
    movl $10,       %ecx    # baza
    movl $s_ispis,  %esi    # string za ispis sume na ekran

brojUString:
    andl %eax,      %eax
    jz obrni

    # provera kapaciteta odredišnog stringa
    cmpb $1,        n
    jb greskaKapaciteta

    xorl %edx,      %edx
    divl %ecx

    addb $'0',      %dl
    movb %dl,      (%esi)
    incl %esi
    decl n
    jmp brojUString

obrni:
    decl %esi
    movl $s_ispis,  %edi

invertuj:
    cmpl %esi,      %edi  # da li su se pokazivači susreli
    jae ispisatiSumu

    movb (%esi),    %al
    movb (%edi),    %ah

    movb  %al,     (%edi)
    movb  %ah,     (%esi)

    decl %esi
    incl %edi
    jmp invertuj

ispisatiSumu:
    # da li je suma 0, ako jeste ispisati gresku
    cmpb $0,        suma
    je ispisGreske

     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal por3,      %ecx
    movl $p3_len,   %edx
    int $0x80

     # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal s_ispis,   %ecx
    movl $10,       %edx
    int $0x80

    # ispis novog reda
    movl $4,        %eax
    movl $1,        %ebx
    leal nl,        %ecx
    movl $2,        %edx
    int $0x80

    jmp kraj

greskaKapaciteta:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal por4,      %ecx
    movl $p4_len,   %edx
    int $0x80
    jmp kraj

ispisGreske:
    # ispis poruke
    movl $4,        %eax
    movl $1,        %ebx
    leal por2,      %ecx
    movl $p2_len,   %edx
    int $0x80

kraj:
    movl $1,        %eax
    movl suma,        %ebx
    int $0x80