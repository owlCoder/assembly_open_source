.section .data
ispis1:     .ascii "Unesite do 20 heksadecimalnih brojeva: \0"
ispis2:     .ascii "Unesite opciju (cifra 1-4): \0"
nl:     .ascii "\n\0"
UNOSLEN = 201
unos:   .fill UNOSLEN,1,0
IZLAZLEN = 21
izlaz:   .fill IZLAZLEN,1,0
lastchar:   .long 0
niz:    .fill 20,4,0
nizlen: .long 0
greska: .long 0
min: .long 0
max: .long 0
sum: .long 0
mean: .long 0
var: .quad 0

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

.macro print_out val
    pushl $10
    pushl $IZLAZLEN
    pushl $izlaz
    pushl \val
    call inter_to_str
    addl $16, %esp
    print_str $izlaz
    print_str $nl
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

#unsigned int inter_to_str(int broj, char* str, unsigned int duz, unsigned int baza)
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
    cmpb $0,(%esi)
    je greska12_lab
next:
    skip_space %esi
    cmpb $0,(%esi)
    je unos_opcije
    cmpl $20, nizlen
    je greska3_lab
    pushl $lastchar
    pushl $16
    pushl $greska
    pushl %esi
    call str_to_inter
    addl $16, %esp
    cmpl $0, greska
    jne greska12_lab
    movl nizlen, %ecx
    movl %eax,niz(,%ecx,4)
    incl nizlen
    movl lastchar, %esi
    jmp next

unos_opcije:
    print_str $ispis2
    get_str $unos, $UNOSLEN

    cmpb $'1', unos
    je min_lab
    cmpb $'2', unos
    je max_lab
    cmpb $'3', unos
    je mean_lab
    cmpb $'4', unos
    je mean_lab
    movl $5, %ebx
    jmp kraj

min_lab:
    movl niz, %eax
    movl %eax, min
    movl nizlen, %esi
    decl %esi

min_loop:
    cmpl $-1, %esi
    je min_end
    movl niz(,%esi,4), %eax
    cmpl %eax, min
    jna old_min
    movl %eax, min
old_min:
    decl %esi
    jmp min_loop

min_end:
    print_out min

    movl $0, %ebx
    jmp kraj

max_lab:
    movl niz, %eax
    movl %eax, max
    movl nizlen, %esi
    decl %esi

max_loop:
    cmpl $-1, %esi
    je max_end
    movl niz(,%esi,4), %eax
    cmpl %eax, max
    jnb old_max
    movl %eax, max
old_max:
    decl %esi
    jmp max_loop

max_end:
    print_out max
    movl $0, %ebx
    jmp kraj

mean_lab:
    xorl %edx, %edx
    xorl %eax, %eax
    movl nizlen, %esi
    decl %esi

sum_loop:
    cmpl $-1, %esi
    je mean_end
    addl niz(,%esi,4), %eax
    adcl $0, %edx
    jc greska4_lab
    decl %esi
    jmp sum_loop

mean_end:
    divl nizlen

    cmpb $'4', unos
    je var_lab

    print_out %eax
    movl $0, %ebx
    jmp kraj

var_lab:
    movl %eax, mean

    movl nizlen, %esi
    decl %esi

var_loop:
    cmpl $-1, %esi
    je var_end
    movl niz(,%esi,4), %ebx
    subl mean, %ebx
    jns pos
    negl %ebx
pos: 
    xorl %edx, %edx
    movl %ebx, %eax
    mull %ebx

    addl %eax, var
    adcl %edx, var+4
    jc greska4_lab

    decl %esi
    jmp var_loop

var_end:
    movl var, %eax
    movl var+4, %edx
    divl nizlen

    print_out %eax

    movl $0, %ebx
    jmp kraj

greska12_lab:
    movl greska, %ebx
    jmp kraj

greska3_lab:
    movl $3, %ebx
    jmp kraj

greska4_lab:
    movl $4, %ebx
    jmp kraj

kraj:
    movl $1, %eax
    int $0x80