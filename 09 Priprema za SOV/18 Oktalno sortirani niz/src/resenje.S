.section .data
ispis1:     .ascii "Unseite do 10 dekadnih brojeva: \0"
ispis2:     .ascii "Sortirani oktalni niz:\0"
greska1:    .ascii "Nekorektan element niza: \0"
greska2:    .ascii "Nema elemenata niza.\n\0"
newlin:     .ascii "\n\0"
UNOSLEN = 151
unos:   .fill UNOSLEN,1,0
lastchar:   .long 0
niz:    .fill 10,4,0
nizlen: .long 0
greska: .long 0
brojs:  .fill 32,1,0

.section .text
.globl main

# ispis stringa na koga pokazuje promenljiva/registar
# (prethodno se računa dužina stringa na osnovu \0)
# makro menja indikatore i registre eax, ebx, ecx i edx
.macro print_str string
    movl $4,%eax
    movl $1,%ebx
    movl \string,%ecx
    movl $0,%edx
1:  cmpb $0,(%ecx)
    je 2f
    incl %ecx
    incl %edx
    jmp 1b
2:  movl \string,%ecx
    int $0x80
.endm

# unos stringa na koga pokazuje promenljiva/registar
# umesto entera, na kraj se stavlja NULL
# makro menja indikatore i registre eax, ebx, ecx i edx
.macro get_str string, length
    movl $3,%eax
    movl $0,%ebx
    movl \string,%ecx
    movl \length,%edx
    int $0x80
    movb $0, -1(%ecx, %eax, 1)
.endm

# preskakanje razmaka u stringu na koga pokazuje registar
# makro menja indikatore i vrednost registra koji je prosleđen
.macro skip_space reg
1:  cmpb $0,(\reg)
    je 3f
    cmpb $' ',(\reg)
    je 2f
    jne 3f
2:
    incl \reg
    jmp 1b
3:
.endm

#int str_to_inter(char* str, unsigned int* greska, unsigned int baza, char* last)
str_to_inter:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    pushl %ebx
    pushl %edi
    movl $1, -4(%ebp)   #negacija
    movl $0, %edi       #greška
    cmpl $2, 16(%ebp)   #provera validnosti baze
    jl s2i_greska3
    cmpl $36, 16(%ebp)
    jg s2i_greska3
    xorl %eax, %eax
    xorl %ecx, %ecx
    movl 8(%ebp), %ebx
    cmpb $0, (%ebx)     #prazan string?
    je s2i_greska2
#    cmpb $'+', (%ebx)   #predznak?
#    je s2i_znak1
#    cmpb $'-', (%ebx)   #predznak?
#    jne s2i_cifra
#    negl -4(%ebp)
#s2i_znak1:
#    incl %ebx           #preskoči predznak
s2i_cifra:
    movb (%ebx), %cl
    andb %cl, %cl
    jz s2i_znak2
    cmpb $' ', %cl
    je s2i_znak2
    subb $'0', %cl
    js s2i_greska2      #znak manji od '0'?
    cmpb $10, %cl       #cifra '0'-'9'?
    jl s2i_cifra2
    subb $'A'-'9'-1, %cl
    js s2i_greska2      #znak između '9' i 'A'?
    cmpb $36, %cl       #cifra 'A'-'Z'?
    jl s2i_cifra2
    subb $'a'-'A', %cl  #cifra 'a'-'z'?
    js s2i_greska2      #znak između 'Z' i 'a'?
s2i_cifra2:
    cmpl 16(%ebp), %ecx
    jae s2i_greska2     #cifra >= baza?
    mull 16(%ebp)
    jc s2i_greska1
    addl %ecx, %eax
    jc s2i_greska1
    incl %ebx
    jmp s2i_cifra
s2i_znak2:
#    andl %eax, %eax
#    js s2i_greska1  #ako je neoznačeni broj veći od 0x7fffffff
#    imull -4(%ebp)
    jmp s2i_kraj
s2i_greska3:
    incl %edi
s2i_greska2:
    incl %edi
s2i_greska1:
    incl %edi
s2i_kraj:
    movl 20(%ebp), %ecx
    movl %ebx, (%ecx)
    movl 12(%ebp), %ecx
    movl %edi, (%ecx)
    popl %edi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

#unsigned int inter_to_str(int broj, char* str, unsigned int duz, unsigned int baza);
inter_to_str:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp
    pushl %ebx
    pushl %esi
    pushl %edi
    movl 8(%ebp), %eax      #broj
    movl 12(%ebp), %edi     #str
    movl 20(%ebp), %ebx     #baza
    movl $0, -4(%ebp)       #greška
#    andl %eax, %eax         #da li je broj negativan?
#    jns i2s_cifra
#    movb $'-', (%edi)       #ako jeste, ubaci minus
#    incl %edi
#    incl 12(%ebp)           #pomeri pokazivač, da se ne bi obrtao minus
#    decl 16(%ebp)           #smanji broj slobodnih mesta
#    negl %eax               #komplement 2
    movb $' ',(%edi)
    incl %edi
    incl 12(%ebp)   #pomeri pokazivač, da se ne bi obrtao razmak
i2s_cifra:
    decl 16(%ebp)           #provera preostalog mesta
    cmpl $1, 16(%ebp)       #neophodan je i 1 bajt za NULL
    jl i2s_greska
    xorl %edx, %edx
    divl %ebx
    cmpb $10, %dl
    jb i2s_manje10
    addb $'A'-'9'-1, %dl    #razlika slova i cifara
i2s_manje10:
    addb $'0', %dl
    movb %dl, (%edi)
    incl %edi
    andl %eax, %eax
    jnz i2s_cifra
    #movb $10, (%edi)
    movb $0, (%edi)
    decl %edi
    movl 12(%ebp), %esi
i2s_obrni:
    cmpl %edi, %esi
    jae i2s_kraj
    movb (%esi), %ah
    movb (%edi), %al
    movb %al, (%esi)
    movb %ah, (%edi)
    decl %edi
    incl %esi
    jmp i2s_obrni
i2s_greska:
    incl -4(%ebp)
i2s_kraj:
    movl -4(%ebp), %eax
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret

main:
    print_str $ispis1
    get_str $unos, $UNOSLEN

    movl $unos, %esi
sledeci_broj:
    skip_space %esi
    cmpb $0,(%esi)
    je daljesort
    pushl $lastchar
    pushl $10
    pushl $greska
    pushl %esi
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska
    movl nizlen, %ecx
    movl %eax,niz(,%ecx,4)
    incl nizlen
    movl lastchar, %esi
    jmp sledeci_broj

daljesort:
    cmpl $0, nizlen
    je prg_greska2
    decl nizlen
    jz ispisstart
sort0:
    movl $0, %ebx   # indikator zamene
    movl $0, %ecx   # indeks
sort1:
    movl niz(,%ecx,4), %eax
    cmpl %eax,niz+4(,%ecx,4)
    jae sort2
    movl niz+4(,%ecx,4), %edx
    movl %eax,niz+4(,%ecx,4)
    movl %edx,niz(,%ecx,4)
    incl %ebx
sort2:
    incl %ecx
    cmpl nizlen, %ecx
    jb sort1
    andl %ebx, %ebx
    jnz sort0
ispisstart:
    print_str $ispis2
    xorl %esi, %esi
ispiselem:
    pushl $8
    pushl $32
    pushl $brojs
    pushl niz(,%esi,4)
    call inter_to_str
    addl $16, %esp
    print_str $brojs
    incl %esi
    cmpl nizlen, %esi
    jbe ispiselem
    print_str $newlin
    movl $0, %ebx
    jmp kraj
prg_greska:
    print_str $greska1
    movl $brojs,%edi
prebaci:
    movb (%esi), %al
    cmpb $' ', %al
    je prebaci2
    andb %al, %al
    je prebaci2
    movb %al,(%edi)
    incl %esi
    incl %edi
    jmp prebaci
prebaci2:
    movb $0,(%edi)
    print_str $brojs
    print_str $newlin
    movl $1, %ebx
    jmp kraj
prg_greska2:
    print_str $greska2
    movl $1, %ebx
kraj:
    movl $1, %eax
    int $0x80

