.section .data
ispis1: .ascii "Unesite izraz: \0"
ispis2: .ascii "Suma brojeva u opsegu je manja.\n\0"
ispis3: .ascii "Suma brojeva van opsega je manja.\n\0"
ispis4: .ascii "Sume su jednake.\n\0"
ispis5: .ascii "Suma: 0x\0"
greska1: .ascii "GRESKA: Prekoracenje prilikom racunanja sume.\n\0"
greska2: .ascii "GRESKA: Problem prilikom konverzije brojeva.\n\0"
UNOSLEN = 101
unos: .fill UNOSLEN,1,0
lastchar: .long 0

g_granica: .long 0
d_granica: .long 0
niz: .fill 10,4,0
niz_br_elemenata: .long 0
greska: .long 0
suma_str: .fill 32,1,0

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

    # Donja granica
    pushl $lastchar
    pushl $10
    pushl $greska
    pushl $unos+1 # Preskace se karakter `[`
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska2
    movl %eax, d_granica

    # Gornja granica
    pushl $lastchar
    pushl $10
    pushl $greska
    incl lastchar # Preskace se karakter `,`
    pushl lastchar
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne prg_greska2
    movl %eax, g_granica

    # Parsiranje niza
    addl $3, lastchar # Preskace se `,]{`
    movl $0, %edi # Ukupan broj elemenata u nizu
parsiraj:
    movl lastchar, %esi
    cmpb $'}', (%esi)
    je sumiraj_start

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

    # Racunanje sume
sumiraj_start:
    movl %edi, niz_br_elemenata
    movl $0, %eax # suma brojeva u opsegu
    movl $0, %edx # suma brojeva van opsega
    movl $0, %edi # i
    movl $0, %esi # vrednost i-tog elementa
sumiraj:
    cmpl niz_br_elemenata, %edi
    jae pronadji_min
    movl niz(,%edi,4), %esi
    cmpl d_granica, %esi
    jb suma_van
    cmpl g_granica, %esi
    ja suma_van
suma_u:
    addl niz(,%edi,4), %eax
    jc prg_greska1
    jmp suma_nastavak
suma_van:
    addl niz(,%edi,4), %edx
    jc prg_greska1
suma_nastavak:
    incl %edi
    jmp sumiraj

    # Pronalazenje manje sume
pronadji_min:
    cmpl %eax, %edx
    je jednake
    jb manja_van
manja_u:
    movl %eax, %edi
    print_str $ispis2
    jmp ispis
manja_van:
    movl %edx, %edi
    print_str $ispis3
    jmp ispis
jednake:
    movl %eax, %edi
    print_str $ispis4

ispis:
    pushl $16
    pushl $32
    pushl $suma_str
    pushl %edi
    call inter_to_str
    addl $16, %esp
    print_str $ispis5
    print_str $suma_str
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
