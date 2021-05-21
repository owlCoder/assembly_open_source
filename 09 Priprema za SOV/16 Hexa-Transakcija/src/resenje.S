.section .data
p_unesi: .ascii "Unesite transakciju: \0"
p_greska: .ascii "Doslo je do greske!\n\0"
p_rez_1od4: .ascii "Preneseno je \0"
p_rez_2od4: .ascii "RSD i na izvornom racunu je ostalo \0"
p_rez_3od4: .ascii "RSD a na odredisnom racunu je sada saldo \0"
p_rez_4od4: .ascii "RSD.\n\0"
MAXU = 51
unos_prm: .fill MAXU
iot_zastave: .fill 3, 1, 0
i: .long 0
o: .long 0
t: .long 0
greska: .long 0

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

.section .text
.globl main

main:
    print_str $p_unesi
    get_str $unos_prm, $MAXU

    movl $unos_prm, %esi
opcija:
    cmpb $0, (%esi)
    je logika
    cmpb $' ', (%esi)
    je dalje_opcija
    cmpb $'i', (%esi)
    je jeste_i
    cmpb $'I', (%esi)
    jne nije_i
jeste_i:
    movl $i, %edx
    cmpb $0, iot_zastave
    jne duplo
    movb $1, iot_zastave
    incl %esi
    jmp brojica
nije_i:
    cmpb $'o', (%esi)
    je jeste_o
    cmpb $'O', (%esi)
    jne nije_o
jeste_o:
    movl $o, %edx
    cmpb $0, iot_zastave+1
    jne duplo
    movb $1, iot_zastave+1
    incl %esi
    jmp brojica
nije_o:
    cmpb $'t', (%esi)
    je jeste_t
    cmpb $'T', (%esi)
    jne nije_t
jeste_t:
    movl $t, %edx
    cmpb $0, iot_zastave+2
    jne duplo
    movb $1, iot_zastave+2
    incl %esi
    jmp brojica
nije_t:
    movl $3, greska
    jmp kraj_greska
duplo:
    movl $1, greska
    jmp kraj_greska
dalje_opcija:
    incl %esi
    jmp opcija

brojica:
    cmpb $0, (%esi)
    je logika
    cmpb $' ', (%esi)
    je dalje_brojica
    cmpb $'0', (%esi)
    jne  nije_t
    incl %esi
    cmpb $'x', (%esi)
    jne nije_t
    incl %esi
    movl %esi, %edi
na_kraj_broja:
    incl %edi
    cmpb $' ', (%edi)
    je kraj_broja
    cmpb $0, (%edi)
    je kraj_broja
    jmp na_kraj_broja
kraj_broja:
    pushl %edx
    pushl %edi
    pushl $16
    pushl $greska
    pushl %esi
    call str_to_inter
    addl $16, %esp
    popl %edx
    movl %eax, (%edx)
    movl %edi, %esi
    cmpl $0, greska
    jnz kraj_greska
    cmpb $1, iot_zastave
    jne o_zastava_je_li
    incb iot_zastave
    jmp opcija
o_zastava_je_li:
    cmpb $1, iot_zastave+1
    jne t_zastava_je_li
    incb iot_zastave+1
    jmp opcija
t_zastava_je_li:
    cmpb $1, iot_zastave+2
    jne greska_2
    incb iot_zastave+2
    jmp opcija

greska_2:
    movl $2, greska
    jmp kraj_greska
greska_1:
    movl $1, greska
    jmp kraj_greska

dalje_brojica:
    incl %esi
    jmp brojica

logika:
    movl iot_zastave, %ecx
    andl $0x20202, %ecx
    cmpl $0x20202, %ecx
    jnz greska_1
    movl t, %eax
    cmpl %eax, i
    jb greska_2
    subl %eax, i
    addl %eax, o
    jc greska_2

#unsigned int inter_to_str(int broj, char* str, unsigned int duz, unsigned int baza);
    print_str $p_rez_1od4
    pushl $10
    pushl $MAXU
    pushl $unos_prm
    pushl t
    call inter_to_str
    addl $4, %esp
    print_str $unos_prm
    print_str $p_rez_2od4
    pushl i
    call inter_to_str
    addl $4, %esp
    print_str $unos_prm
    print_str $p_rez_3od4
    pushl o
    call inter_to_str
    addl $16, %esp
    print_str $unos_prm
    print_str $p_rez_4od4
    jmp kraj
kraj_greska:
    print_str $p_greska
kraj:
    movl $1, %eax
    movb greska, %bl
    int $0x80

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
    cmpl %ebx, 20(%ebp)
    jz s2i_znak2
    movb (%ebx), %cl
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
s2i_greska2:
s2i_greska1:
    movl $3, %edi
s2i_kraj:
#    movl %ebx, %eax
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