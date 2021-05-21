.section .data
ispis1: .ascii "Unesite izraz: \0"
ispis2: .ascii "Ukupno brojeva koji ispunjavaju uslov: 0x\0"
greska1: .ascii "GRESKA: Prekoracenje kod provere uslova.\n\0"
greska2: .ascii "GRESKA: Problem prilikom konverzije brojeva.\n\0"
UNOSLEN = 101
unos: .fill UNOSLEN,1,0
lastchar: .long 0

n: .long 0
m: .long 0
niz: .fill 20,4,0
niz_br_elemenata: .long 0
greska: .long 0
akumulator_str: .fill 32,1,0

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
    cmpb $',', %cl
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
    movb $10, (%edi)
    movb $0, 1(%edi)
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
    get_str $unos $UNOSLEN

    # n=
    pushl $lastchar
    pushl $10
    pushl $greska
    pushl $unos+2 # Preskace se `n=`
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska2
    movl %eax, n

    # m=
    pushl $lastchar
    pushl $10
    pushl $greska
    addl $3, lastchar # Preskace se `,m=`
    pushl lastchar
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska2
    movl %eax, m

    # Parsiranje niza
    addl $6, lastchar # Preskace se `,niz={`
    movl $0, %edi # Ukupan broj elemenata u nizu
parsiraj:
    movl lastchar, %esi
    cmpb $'}', (%esi)
    je izbroj_start

    pushl $lastchar
    pushl $10
    pushl $greska
    pushl %esi
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska2
    movl %eax, niz(,%edi,4)

    incl lastchar
    incl %edi
    jmp parsiraj

    # Brojanje koliko ima elemenata koji ispunjavaju uslov
izbroj_start:
    decl %edi
    movl %edi, niz_br_elemenata
    movl $0, %ecx # akumulator
    movl $1, %edi # i
izbroj:
    cmpl niz_br_elemenata, %edi
    jge ispis
    # Prethodni element se mnozi sa n
    movl -4+niz(,%edi,4), %eax
    mull n
    jc prg_greska1
    # Sledeci element se umanjuje za m
    movl 4+niz(,%edi,4), %edx
    subl m, %edx
    jc prg_greska1
    # Provera uslova
    cmpl niz(,%edi,4), %eax
    ja preskoci
    cmpl %edx, niz(,%edi,4)
    ja preskoci
    incl %ecx
preskoci:
    incl %edi
    jmp izbroj

ispis:
    pushl $16
    pushl $32
    pushl $akumulator_str
    pushl %ecx
    call inter_to_str
    addl $16, %esp
    print_str $ispis2
    print_str $akumulator_str
    movl $0, %ebx
    jmp kraj

prg_greska1:
    print_str $greska1
    movl $1, %ebx
    jmp kraj
prg_greska2:
    print_str $greska2
    movl $1, %ebx
    jmp kraj
kraj:
    movl $1, %eax
    int $0x80
